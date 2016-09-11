namespace :misc  do
  task :reset_counters => :environment do
    Item.update_all :hits => 0
    Category.update_all :hits => 0
    Subcategory.update_all :hits => 0
    Order.destroy_all 
  end
end