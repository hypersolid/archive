class Users::ItemsController < Users::ApplicationController
  before_action :find_order
  before_action :find_item, only: [:update, :destroy, :move]

  respond_to :html, :js, :json

  def create
    @item = @order.items.new item_params
    respond_to do |format|
      if @item.save
        format.js { render :create }
      else
        format.js { render :failure }
      end
    end
  end

  def update
    @item.update_attributes item_params
    respond_with @item
  end

  def destroy
    @item.destroy
    respond_to do |format|
      format.js { render :destroy }
    end
  end

  def move
    @items = @order.items.order('position DESC')
    if params[:d] == 'up'
      @item.move_up
    else
      @item.move_down
    end
  end

  private
  def find_order
    @order = Order.find params[:order_id]
  end

  def find_item
    @item = @order.items.find params[:id]
  end

  def item_params
    params.require(:item).permit!
  end
end
