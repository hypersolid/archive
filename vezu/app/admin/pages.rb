# encoding: utf-8

ActiveAdmin.register Page do
  actions :all, :except => [:show]
  
  index do
    column :id
    column :slug
    column :header
    column "Link" do |p|
      raw "<a href='/pages/#{p.slug}'>Посмотреть на сайте</a>"
    end
    
    default_actions
  end
  
  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Details" do
      f.input :slug, :label => "Метка"
      f.input :header, :label => "Заголовок"
      f.input :content, :label => "Контент (html)"
    end
    f.buttons
  end
end