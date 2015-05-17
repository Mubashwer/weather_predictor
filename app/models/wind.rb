class Wind < ActiveRecord::Base
  belongs_to :observation
  
  # Grabbed from Stack Overflow ()
  def self.bearing_to_cardinal bearing
    val = (bearing/22.5).round
    arr = ["N","NNE","NE","ENE","E","ESE", "SE", "SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"]
	return arr[val % 16]
  end
end
