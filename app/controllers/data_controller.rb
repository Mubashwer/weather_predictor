class DataController < ApplicationController
  
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
  
end
