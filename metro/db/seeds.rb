City.destroy_all

open("db/import/cities.txt").read.each_line do |city|
  name, caption, openingyear,  stations,  length, country = city.chomp.split("\t")
  unless City.find_by_city_name(name)
    puts 'Creating ' + name
    City.create!(:city_name => name, :metro_name => caption, :openingyear => openingyear, :country => country, :nstations => stations)
  end
end

open("db/import/cities_additional.txt").read.each_line do |city|
  name, latlon, bounds, full_name = city.chomp.gsub('(','').gsub(')','').split("\t").map(&:strip)
  c = City.find_by_city_name(name)
  puts 'Updating ' + name
  c.update_attributes(:full_name => full_name, :bounds => "[#{bounds}]", :lat => latlon.split(',')[0], :lon => latlon.split(',')[1]) rescue nil
end
