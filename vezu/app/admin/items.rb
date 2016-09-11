# encoding: utf-8

ActiveAdmin.register Item do
  actions :all, :except => [:show]

  index do
    column :id
    column :hits
    column "Image" do |c|
      raw "<a href='/admin/items/#{c.id}/edit'><img src='#{c.img(:tiny)}'/></a>"
    end
    column "Name" do |c|
      raw "<a href='/admin/items/#{c.id}/edit'>#{c.name}</a>"
    end
    column "Category" do |c|
      raw "<a href='/admin/categories/#{c.category.id}/edit'>#{c.category.name}</a>" if c.category
    end
    column "Subcategory" do |c|
      raw "<a href='/admin/subcategories/#{c.subcategory.id}/edit'>#{c.subcategory.name}</a>" if c.subcategory 
    end
    column "Firm" do |c|
      raw "<a href='/admin/firms/#{c.firm.id}/edit'>#{c.firm.name}</a>" if c.firm
    end
    column :price
    column :weight
    
    default_actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Details" do
      f.input :img, :as => :file, :hint => f.template.image_tag(f.object.img.url(:thumb)), :label => "Картинка"

      f.input :subcategory, :label => "Категория/Подкатегория", :collection => Subcategory.all.sort_by(&:full_name).map{ |s| [s.full_name, s.id] }
      
      f.input :firm, :label => "Фирма"

      f.input :name, :label => "Название"
      f.input :description, :label => "Описание"
      f.input :note, :label => "Примечание"
      f.input :price, :label => "Цена"
      f.input :weight, :label => "Вес"
    end
    f.buttons
  end
  
  
end
