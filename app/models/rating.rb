class Rating < ActiveRecord::Base
  attr_accessible :value

  belongs_to :post
  belongs_to :user
end
