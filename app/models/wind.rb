class Wind < ActiveRecord::Base
  
  belongs_to :observation
  attr_accessor :saved
  @@saved = nil

  # Grabbed from Stack Overflow ()
  def self.bearing_to_cardinal bearing
    val = (bearing/22.5).round
    arr = ["N","NNE","NE","ENE","E","ESE", "SE", "SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"]
	return arr[val % 16]
  end
  
  def self.predict wind_set, times, periods, m
	if m == "wind_direction"
		return @@saved
	else
		@@saved = nil
	end

	wind_prediction_hash = {}
	time_hash = {}
	if wind_set
		#wind_set = wind_set.map{|wind| wind.wind}
		x_strength = wind_set.map{|wind| wind.speed*Math.sin(-((wind.bearing + 90) % 360)*Math::PI / 180)}
		y_strength = wind_set.map{|wind| wind.speed*Math.cos(-((wind.bearing + 90) % 360)*Math::PI / 180)}
		epoch = wind_set.first.unix_time + 1

		time_hash = {wind_direction: {}, wind_speed: {}}
		begin
		predicted_x_strength = Regression.get_value(wind_set.map{|wind| wind.unix_time - epoch}, x_strength, times)
		predicted_y_strength = Regression.get_value(wind_set.map{|wind| wind.unix_time - epoch}, y_strength, times)
		combined_x_y = times.each_with_index.map do |time, i|
			# I don't think we should do bearing_to_cardinal until after our aggregation.
			#wind_direction = Wind.bearing_to_cardinal(-Math.atan2(predicted_x_strength[:value][i], predicted_y_strength[:value][i]) + 90)
			wind_direction = ((-Math.atan2(predicted_x_strength[:value][i], predicted_y_strength[:value][i])*Math::PI*180) - 90 + 360) % 360
			
			wind_speed = Math.sqrt((predicted_x_strength[:value][i]**2) + (predicted_y_strength[:value][i]**2)).round(2).abs
			# Map to the hash.
			{wind_direction: wind_direction, wind_speed: wind_speed}
			#r2 = ((predicted_x_strength[:r2] + predicted_y_strength[:r2])/2.0).round(2)
		end
		periods.each_with_index do |p, i|
			x_y_sum_strength = predicted_x_strength[:value][i] + predicted_y_strength[:value][i]
			
			time_hash[:wind_direction][p] = combined_x_y[i][:wind_direction]
			# Each value may have a different r^2 value based on the distribution of distances in the radial plane
			# Hence it may be worth splitting these values out more.
			# r2 simply expressed as weighted linear percentage weighted average
			time_hash[:wind_direction][:r2] = (predicted_x_strength[:r2]*(predicted_x_strength[:value][i]/x_y_sum_strength) + predicted_y_strength[:r2]*(predicted_y_strength[:value][i]/x_y_sum_strength))/2
			time_hash[:wind_speed][p] = combined_x_y[i][:wind_speed]
			time_hash[:wind_speed][:r2] = (predicted_x_strength[:r2]*(predicted_x_strength[:value][i]/x_y_sum_strength) + predicted_y_strength[:r2]*(predicted_y_strength[:value][i]/x_y_sum_strength))/2
		end
		rescue
		periods.each do |p|
			time_hash[:wind_direction][p] = {} if time_hash[:wind_direction][p].class != {}.class
			time_hash[:wind_speed][p] = {} if time_hash[:wind_speed][p] != {}.class
			time_hash[:wind_speed][p].keys.each do |key|
				time_hash[:wind_speed][p][key] = [] if time_hash[:wind_speed][p][key] != [].class
			end
			time_hash[:wind_direction][p].keys.each do |key|
				time_hash[:wind_direction][p][key] = [] if time_hash[:wind_direction][p][key] != [].class
			end
			time_hash["wind_direction"][p][:value] = 0
			time_hash["wind_direction"][p][:r2] = 0.0
			time_hash["wind_speed"][p][:value] = 0
			time_hash["wind_speed"][p][:r2] = 0.0
		end
		end

	end
	
	if(time_hash)
		@@saved = time_hash
	else
		@@saved = {"wind"=>"unpredicted"}
	end
	return @@saved
	
  end
end
