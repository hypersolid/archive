class DispatchLoggingService < Logger
  include Singleton

  SIGNATURE_PADDING = 30

  class << self
    delegate :notify, to: :instance
  end

  def initialize
    super(Rails.root.join('log/dispatch.log'))
    @ring_buffer = Gazeta::RingBuffer.new(1000)
    self.formatter = formatter
  end

  def notify(event, *args)
    return if Rails.env.test?
    send("log_#{event}_event", *args)
  end

  def formatter
    proc { |_severity, _time, _progname, msg| "#{msg.to_s.strip}\n" }
  end

  def formatted_recipient(recipient)
    "#{recipient.class.to_s.sub('Gazeta::', '')}##{recipient.id}"
  end

  def formatted_caller(offset = 3, depth = 6)
    caller[offset, depth - offset].map do |line|
      line = line.split(':in').first
      [*line.split('/')[-3, 3]].join('/')
    end.join(', ')
  end

  def log(message)
    formatted_time = Time.zone.now.strftime('%Y%m%d %H:%M:%S')
    info("#{formatted_time}  #{message.strip}")
  end

  def entail_log(message, prefix)
    info("#{prefix} #{' ' * 17}  #{message}")
  end

  def log_dispatch_failure_event(message, backtrace)
    log("FAILED with '#{message}''")
    backtrace[0, 7].each { |line| entail_log(line, '♦') }
  end

  def log_dispatch_associations_event(items, _options)
    amount = items.count
    items_type = items.first.class.to_s.demodulize.downcase.pluralize(amount)
    items_list = amount < 10 ? items.map(&:id).join(', ') : '...'
    entail_log("links to #{amount} #{items_type} [#{items_list}]", '♥')
  end

  def log_dispatch_event(recipient, options = {})
    recipient_signature = formatted_recipient(recipient)
    caller_signature = formatted_caller
    log("#{recipient_signature.ljust(SIGNATURE_PADDING)} from #{caller_signature} with #{options}")

    entail_linked_dispatch_events(recipient_signature)

    @ring_buffer.push(recipient: recipient_signature, options: options, caller: caller_signature, time: Time.now)
  end

  def entail_linked_dispatch_events(recipient_signature)
    @ring_buffer.search do |object|
      object[:recipient] == recipient_signature
    end.each do |match|
      time_ago = "triggered #{(Time.zone.now - match[:time]).round(3)}s ago".ljust(SIGNATURE_PADDING)
      source = " from #{match[:caller]} with #{match[:options]}"
      entail_log(time_ago + source, '♠')
    end
  end
end
