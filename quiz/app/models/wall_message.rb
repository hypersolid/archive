# encoding: utf-8
class WallMessage < ActiveRecord::Base
  after_create :send_email

  belongs_to :sender, :class_name => "User"
  belongs_to :recipient, :class_name => "User"

  private
  def send_email
    if self.sender != self.recipient
      EmailFallback.delay.proxy(:wall_message, self) if self.recipient.email_wall_message?
    end
  end
end