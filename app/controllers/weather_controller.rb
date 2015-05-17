class WeatherController < ApplicationController
  def locations
  end
  
  def data_postcode
	
  end
  
  def data_location_id
	@location = Location.find_by(station_id: params["location_id"])
	if @location
		if params.has_key?("date")
			#@obs = Observation.get_data([@location],params["date"])
		end
		@current_weather = Observation.get_current_weather(@location)
	end
  end
  
  def prediction
	if params.has_key?("postcode")
		lat_long = Location.get_lat_long params["postcode"]
	else
		lat_long = [params["lat"],params["long"]]
	end
	@predictions = Observation.get_predictions(lat_long[0], lat_long[1], params["period"])
  end
end
