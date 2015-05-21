class Observation < ActiveRecord::Base
  belongs_to :location
  has_one :rainfall
  has_one :wind
  has_one :temperature
  MEASUREMENTS = ["rain", "temp"]

  def self.get_current_weather location
    
    lower_bound = Time.zone.now - 30.minutes
    obs = Observation.where(location_id: location.id).last
    if location.last_update > lower_bound
        return {"current_cond"=>('"' + obs.condition.to_s + '"'), "current_temp"=>'"' + obs.temperature.temp.to_s + '"'}
    else
        return {"current_cond"=>"null", "current_temp"=>"null"}
    end
  end
  
    def as_json(options ={})
        my_hash = {"time" => Time.zone.at(unix_time).strftime("%H:%M:%S %P"), 
                   "temp" => temperature.temp.to_s,
                   "precip" => (rainfall.intensity).round(2).to_s + "mm",
                   "wind_direction" => Wind.bearing_to_cardinal(wind.bearing),
                   "wind_speed" => wind.speed.to_s}
        return my_hash
    end
   
  # Inverse distance weighting: takes arrays of values and their respective distances from chosen point
  # returns the aggregated value of the chosen point
  def self.aggregate(values, distances)
    inv_distances = distances.map{|d| 1.0/d }
    numerator = 0
    values.each_with_index do |v,i|
      numerator += v * inv_distances[i]
    end
    return numerator.to_f/inv_distances.sum
  end
=begin
  def self.get_predictions lat, long, period
    nearby_locations = Location.get_nearest_locs(lat, long)
    p = Prediction.new(period.to_i)
    d = {}
    periods = (0..period.to_i/10).map{|x| x*10}
    epoch = Observation.first.unix_time + 1
    times = periods.map{|period| Time.zone.now.to_i + period.minutes - epoch}
    nearby_locations[0..1].each do |nearby_location|
        d[nearby_location[:loc].station_id] = Wind.predict(Wind.joins(:observation).where("observations.location_id = ?",nearby_location[:id]),periods)
    end
    return d
  end
=end

#grady: ADD WIND TO p.data in this or separate function
  def self.get_predictions lat, long, period
    nearby_locations = Location.get_nearest_locs(lat, long)
    p = Prediction.new(period.to_i) #check initialize of Prediction
    periods = (10..period.to_i).step(10).to_a # 0 is for current conditions
    epoch = Observation.first.unix_time + 1

    #times = periods.map{|x| (Time.zone.parse(p.data[x.to_s]["time"]) - epoch).to_i} #use times from the prediction object and adjust for epoch
    
    # presumes time at start of day is 1 second (otherwise the values are too large)
    times_hack = periods.map{|x| (Time.zone.parse(p.data[x.to_s]["time"]) - Time.zone.parse(p.data[x.to_s]["time"][8..-1])).to_i + 1}
    
    MEASUREMENTS.each do |m|
        data = {}; data[m] = {}
        distances = []
        nearby_locations[0..1].each_with_index do |loc, i|
            # get data for each location (the data is hash with each period and r2)
            data[m][i] = Temperature.predict(Temperature.joins(:observation).where("observations.location_id = ?",loc[:id]), times_hack, periods) if(m == "temp")
            data[m][i] = Rainfall.predict(Rainfall.joins(:observation).where("observations.location_id = ?",loc[:id]), times_hack, periods) if(m == "rain")
            distances << loc[:distance] # distances array for aggregation

            # add the data values to aray for aggregation
            periods.each_with_index do |per|
                p.data[per.to_s][m]["value"] = [] if p.data[per.to_s][m]["value"].class != Array
                p.data[per.to_s][m]["value"] << data[m][i][per] if data[m][i] 
            end
        end

        periods.each do |per|
            if p.data[per.to_s][m]["value"].compact.count != 2 # error checking
                p.data[per.to_s][m]["value"] = "null"
                next
            end
            agg = Observation.aggregate(p.data[per.to_s][m]["value"], distances).round(2) #aggregate data for each period
            agg = agg.abs if(m == "rain")
            p.data[per.to_s][m]["value"] = agg.to_s 
            p.data[per.to_s][m]["probability"] = data[m][0][:r2].round(2).to_s
        end
    end

    return p.data
  end



  # gets observation data for given location and date
  def self.get_measurements(date, loc)
    start_of_day = Time.zone.parse(date).to_i
    end_of_day = (Time.zone.parse(date) + 1.day).to_i
    return Observation.where("unix_time >= ? AND unix_time <= ? AND location_id = ?", start_of_day, end_of_day, loc.id).order("created_at DESC")
  end
end
