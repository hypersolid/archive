namespace :misc do
   task :reset_counters => :environment do
     Vote.destroy_all
     Brand.all.map{|b| b.votes_count=0;b.votes_stored=0;b.save}
   end
   
   task :janitor  => :environment do
     Fight.all.each do |f|
       if f.brands.size!=2
         puts "Fight #{f.id} #{f.title} will be destroyed"
         f.destroy
       end      
     end
     Brand.all.each do |b|
       if b.fight==nil
         puts "Brand #{b.id} #{b.title} will be destroyed"
         b.destroy
       end
     end
   end
end