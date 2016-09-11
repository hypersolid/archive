# encoding: utf-8

ActiveAdmin.register Order do
  actions :index

  index do
    column :created_at
    column :page
    column :ip
    column :total
    column "rendered" do |o|
      raw o.content
    end
  end  
  
end
