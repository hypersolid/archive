class Vote < ActiveRecord::Base
  belongs_to :brand,  :counter_cache => true
end

