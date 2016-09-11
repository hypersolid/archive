class ItemsController < ApplicationController

  def hit
    item = Item.find(params[:id])
    if Time.now - item.updated_at > 5.seconds
      item.hit!
      item.subcategory.hit!
    end
    render :text => 'woof!'
  end
  
end
