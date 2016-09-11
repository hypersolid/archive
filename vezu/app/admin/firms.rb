# encoding: utf-8

ActiveAdmin.register Firm do
  actions :all, :except => [:show]

  index do
    column :id
    column :hits
    column "Image" do |c|
      raw "<a href='/admin/firms/#{c.id}/edit'><img src='#{c.img(:tiny)}'/></a>"
    end
    column "Name" do |c|
      raw "<a href='/admin/firms/#{c.id}/edit'>#{c.name}</a>"
    end
    
    default_actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Details" do
      f.input :img, :as => :file, :hint => f.template.image_tag(f.object.img.url(:thumb)), :label => "Картинка"
      
      f.input :name, :label => "Название"
      f.input :description, :label => "Описание"
      f.input :phones, :label => "Телефоны (через запятую)"
      f.input :site, :label => "Сайт"
      f.input :social_vk, :label => "Страница vk"
      f.input :social_fb, :label => "Страница fb"
      f.input :conditions, :label => "Условия заказа"
      f.input :exceptions, :label => "Акции" 
      f.input :openinghours, :label => "Часы работы ('ежедневно 9:00-22:00' или 'пн-чт 10:00-21:00,пт-вс круглосуточно')"
    end
    f.buttons
  end
end
