class Wind < ActiveRecord::Base
  belongs_to :observation
  
  # Grabbed from Stack Overflow ()
  def self.bearing_to_cardinal bearing
    val = (bearing/22.5).round
    arr = ["N","NNE","NE","ENE","E","ESE", "SE", "SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"]
	return arr[val % 16]
  end
  
  def self.predict wind_set, times
	wind_prediction_hash = {}
	if wind_set
		#wind_set = wind_set.map{|wind| wind.wind}
		x_strength = wind_set.map{|wind| wind.speed*Math.sin(-((wind.bearing + 90) % 360)*Math::PI / 180)}
		y_strength = wind_set.map{|wind| wind.speed*Math.cos(-((wind.bearing + 90) % 360)*Math::PI / 180)}
		epoch = Wind.first.unix_time + 1
		times.each do |time|
			time_hash = {}
			begin
			predicted_x_strength = Regression.get_value(wind_set.map{|wind| wind.unix_time - epoch}, x_strength, times)
			predicted_y_strength = Regression.get_value(wind_set.map{|wind| wind.unix_time - epoch}, y_strength, times)
			#wind_direction = Wind.bearing_to_cardinal(Math.atan2(predicted_x_strength[:value][0], predicted_y_strength[:value][0]))
			#wind_speed = Math.sqrt((predicted_x_strength[:value][0]**2) + (predicted_y_strength[:value][0]**2)).round(2).abs
			#r2 = ((predicted_x_strength[:r2] + predicted_y_strength[:r2])/2.0).round(2)

			rescue
			predicted_x_strength = "Failed"
			predicted_y_strength = "Failed"
			end
			time_hash["x"] = predicted_x_strength.to_s
			time_hash["y"] = predicted_y_strength.to_s
			wind_prediction_hash[time] = time_hash
		end
	end
	
	if(wind_prediction_hash)
		return wind_prediction_hash
	else
		return {"wind"=>"unpredicted"}
	end
	
  end
end
