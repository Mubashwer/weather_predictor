class PredictionController < ApplicationController
  
  def prediction
    lat_long = params.has_key?("postcode") ? Location.get_lat_long(params["postcode"]) : [params["lat"].to_f, params["long"].to_f]
    @periods = (0..params["period"].to_i).step(10).to_a
    @predictions = Observation.get_predictions(lat_long[0], lat_long[1], params["period"])
  end
  
end
