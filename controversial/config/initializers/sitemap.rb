Sitemap::Map.draw do

  url root_url, :last_mod => DateTime.now, :change_freq => 'daily', :priority => 1

  Fight.all.each do |f|
    url "http://controversialmatter.com"+f.url, :last_mod => Time.now, :change_freq => 'daily', :priority => 0.9
  end


end