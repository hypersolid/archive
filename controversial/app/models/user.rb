class User < ActiveRecord::Base
  devise :database_authenticatable, :trackable, :token_authenticatable

  attr_accessible :email, :password, :password_confirmation, :remember_me
end
