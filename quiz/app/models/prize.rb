class Prize < ActiveRecord::Base
  belongs_to :tournament

  validates :position, :uniqueness => { :message => "already exists", :scope => :tournament_id }
end
