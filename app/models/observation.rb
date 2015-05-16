class Observation < ActiveRecord::Base
  belongs_to :location
  has_one :rainfall
  has_one :wind
  has_one :temperature

end
