class WallMessagesController < ApplicationController

  def create
    if signed_in? && !params[:wall_message][:text].blank? 
      @message = WallMessage.create(params[:wall_message].merge({:sender_id => current_user.id}))
    end 
  end
  
  def more
    @user = User.find(params[:user_id])
    @messages = @user.wall_messages.where('wall_messages.id < ?', params[:message_id].to_i).joins(:sender).all(:limit => params[:messages_count].to_i)
    @show_more_link = @user.wall_messages.where('id < ?', @messages.last.id).count > 0
  end

  def destroy
    @message = WallMessage.find(params[:id])
    @message.destroy if current_user.admin?
  end

end