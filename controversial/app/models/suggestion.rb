class Suggestion < ActiveRecord::Base
  belongs_to :brand
  
  default_scope :order=>"created_at DESC"
  scope :recent,:order=>"created_at DESC",:limit=>100
end
