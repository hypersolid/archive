ActiveAdmin.register Category do
  actions :all, :except => [:show]

  index do
    column :id
    column :hits
    column "Image" do |c|
      raw "<a href='/admin/categories/#{c.id}/edit'><img src='#{c.img(:tiny)}'/></a>"
    end
    column "Name" do |c|
      raw "<a href='/admin/categories/#{c.id}/edit'>#{c.name}</a>"
    end
    column "Subcategories" do |c|
      c.subcategories.count
    end
    column "Items" do |c|
      c.items.count
    end
    column "Firms" do |c|
      c.firms.count
    end
    
    default_actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Details" do
      f.input :name
      f.input :img, :as => :file, :hint => f.template.image_tag(f.object.img.url(:thumb))
      f.input :description
    end
    f.buttons
  end
end
