#!/bin/env ruby
# encoding: utf-8

ActiveAdmin.register Subcategory do
  actions :all, :except => [:show]

  index do
    column :id
    column :hits
    column "Name" do |c|
      raw "<a href='/admin/subcategories/#{c.id}/edit'>#{c.name}</a>"
    end
    column "Category" do |c|
      raw "<a href='/admin/categories/#{c.category.id}/edit'>#{c.category.name}</a>" if c.category
    end
    
    default_actions
  end

end