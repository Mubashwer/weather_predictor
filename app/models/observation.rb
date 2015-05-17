class Observation < ActiveRecord::Base
  belongs_to :location
  has_one :rainfall
  has_one :wind
  has_one :temperature

  def self.get_current_weather location
	
	lower_bound = Time.now - 30.minutes
	obs = Observation.where(location_id: location.id).last
	if location.last_update > lower_bound
		return {"current_weather"=>('"' + obs.condition.to_s + '"'), "current_temp"=>'"' + obs.temperature.temp.to_s + '"'}
	else
		return {"current_weather"=>"null", "current_temp"=>"null"}
	end
  end
  
  def as_json(options ={})
        my_hash = {"time" => Time.at(unix_time).strftime("%H:%M:%S %P"), 
				   "temp" => temperature.temp.to_s,
                   "precip" => (rainfall.intensity*600).to_s + "mm",
				   "wind_direction" => Wind.bearing_to_cardinal(wind.bearing),
				   "wind_speed" => wind.speed.to_s}
        return my_hash
    end
	
  def self.get_predictions lat, long, period
	nearby_locations = Location.get_nearest_locs lat, long
	p = Prediction.new
	nearby_locations.each do |nearby_location|
		
	end
	return {"0"=>{"time"=>"12.34pm","rain"=>{"value"=>"2","probability"=>"3"},"temp"=>{"value"=>"34.23","probability"=>"9001"},"wind"=>{"wind-speed"=>"43km/h","wind-direction"=>"PPO"}}}
  end
  
end
