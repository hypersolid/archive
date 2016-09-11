require 'socket'
require 'tempfile'
require 'securerandom'

Thread.abort_on_exception=true

def form_data
  client_id = SecureRandom.uuid
  <<EOF
HTTP/1.0 200 OK
Content-Type: text/html

<html>
  <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.js"></script>
  <script>
    $(function() {
      timeframe = 5000
      
      window.progress = function(position, time, cb) {
        if (!time) time = 0;
        if (!cb) cb = function() {};
        $('#progressbar').stop(true,true).animate({'width': position}, time, "linear", cb);
      }
      
      $("input[type=submit]").click(function(e){
        $(this).attr("disabled", "disabled");
        $('#progressbar').css('width', '0%');
        $('#progressbar').data('position', '0%');

        $('form').submit();

        animate_interval = setInterval(function() {
          window.progress($('#progressbar').data('position'), timeframe);
        }, timeframe);

        update_interval = setInterval(function() {
          $.ajax({
            url: '/status/#{client_id}',
            success: function(data) {
              $('#progressbar').data('position', parseFloat(data) + '%')
            }
          });
        }, timeframe/2);
      });

      $("iframe").load(function(){
        if (typeof update_interval !== 'undefined') {
          clearInterval(update_interval);
          clearInterval(animate_interval);
          
          window.progress('100%', timeframe/4, function(){
            file_name = $("input[type=file]")[0].value.replace("C:\\\\fakepath\\\\", "");
            $('#results').append('<p>' + file_name + ' was uploaded</p>');
            $("input[type=submit]").removeAttr("disabled");
            $('form')[0].reset();
          });
        };
      });
    });
  </script>
  <style>
    #progressbar-wrapper {
      border: 1px solid gray;
      width: 300px;
      padding: 1px;
    }
    #progressbar {
      width: 0%;
      height: 10px;
      background-color: green;
    }
  </style>
  <body>
  <h1>File uploader</h1>
  <form method='post' enctype='multipart/form-data' target='iframe-transport' action="/#{client_id}">
    <input name="file" type="file" value="Select file" />
    <input type="submit" value="Submit" />
  </form>
  <iframe id="iframe-transport" name="iframe-transport" height="0" width="0" frameborder="0"></iframe>
  <div id="progressbar-wrapper">
    <div id="progressbar" data-position="0%"></div>
  </div>
  <div id="results"></div>
  </body>
</html>
EOF

end

PERCENT_DATA = <<EOF
HTTP/1.0 200 OK
Content-Type: text/html


EOF

POST_OK_DATA = <<EOF
HTTP/1.0 200 OK



EOF

# Ubuntu specific implementation (otherwise recv and gets socket methods just gets hanged)
def recv(socket, size)
    reads, writes, errors = IO.select([socket], nil, nil, 0.1)
    socket.recv(size) if reads
end

def store_file(source_path, data_length, file_name) 
  source = File.open(source_path, 'rb')
  target = File.open(file_name, 'wb')
  
  source.seek -data_length, IO::SEEK_END
  
  posted_data = source.read(data_length)
  processed_data = posted_data.split("\r\n")[4..-2]
  target.write processed_data.join("\r\n")
  
  source.close
  target.close
end

def parse_header(data)
  data = data.encode('UTF-8', invalid: :replace, undef: :replace, replace: "")
  length = data.match(/Content-Length: (\d+)/)[1].to_i
  name = data.match(/filename="(.*?)"\r\n/)[1].split('\\').last
  client_id = data.match(/^POST \/(.*?) /)[1]
  [name, length, client_id] 
end

progress_hash = {}

Socket.tcp_server_loop(10001) do |socket, client_addrinfo|

    Thread.start do
      puts '--'
      request_method = recv(socket, 60)
      if request_method
        puts "method: #{request_method.split(' ').first}"
        if request_method =~ /^GET /
          # we need to dump the rest of incoming stream somewhere to start writing
          recv(socket, 1e6)
          puts "mode: status"
          query = request_method.match(/ \/status\/(.*?) /)
          client_id = query[1] if query
          if client_id
            progress = 0
            progress = progress_hash[client_id] * 100 if progress_hash[client_id]
            puts "client_id #{client_id} upload (currently #{progress.round(2)}%)"
            socket.write PERCENT_DATA + progress.to_s
          else
            puts "mode: main form"
            socket.write form_data
          end
        else
          puts "mode: upload"
          storage = Tempfile.new 'storage'
  
          # First of all we need to receive and parse request header
          
          header_data = request_method
          while chunk = recv(socket, 2000)
            header_data += chunk
            break if header_data.scan(/(Content-Type)/).length > 1 && header_data.include?('filename=')
          end
          storage.write header_data
          name, length, client_id = parse_header header_data
          
          puts "file name: #{name}, request body length: #{length}, client id: #{client_id}"
          
          # Then goes the data... in bigger chunks and with precise length calculations 
          
          # somehow I've constantly got
          # undefined method `sum' for [151, 33]:Array (NoMethodError)
          # so had to use reduce instead
          uploaded = header_data.split("\r\n\r\n").map(&:size)[1..-1].reduce{|a, b| a + b}
          while chunk = recv(socket, 1e5)
            storage.write chunk
            uploaded += chunk.length

            progress_hash[client_id] = uploaded.to_f / length
        
            #sleep 1
          end
    
          # Here we remove unnecessary parts from our request
  
          storage.close
          store_file(storage.path, length, name)
    
          socket.write POST_OK_DATA
    
          puts "file #{name} was processed"
        end
  
      end

      socket.close
    end

end