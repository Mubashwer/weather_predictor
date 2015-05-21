class WeatherController < ApplicationController
  def index
  end

  def locations
    @locations = Location.all
  end
  
  def data_postcode
    @postcode = params["postcode"] if params.has_key?("postcode")
    @date = params["date"] if params.has_key?("date")
    @locations = Location.get_locs_by_postcode(@postcode)
    @locs_json = Location.get_locs_json(@locations, @date)
  end
  
  def data_location_id
    date = params["date"] if params.has_key?("date")
    @location = Location.find_by(station_id: params["location_id"])
    if @location
        @measurements = Observation.get_measurements(date, @location) if params.has_key?("date")
        @current_weather = Observation.get_current_weather(@location)
    end
  end
  
  def prediction
    lat_long = params.has_key?("postcode") ? Location.get_lat_long(params["postcode"]) : [params["lat"].to_f, params["long"].to_f]
    @predictions = Observation.get_predictions(lat_long[0], lat_long[1], params["period"])
  end
end
