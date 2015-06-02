class Observation < ActiveRecord::Base
  belongs_to :location
  has_one :rainfall
  has_one :wind
  has_one :temperature
  MEASUREMENTS = ["rain", "temp", "wind_speed", "wind_direction"]

  def self.get_current_weather location
    
    lower_bound = Time.zone.now - 30.minutes
    obs = Observation.where(location_id: location.id).last
    if !location.last_update.nil? and location.last_update > lower_bound and obs != nil
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
    inv_distances = distances.map{|d|  d < 1 ? 1 : 1.0/d  }
    numerator = 0
    values.each_with_index do |v,i|
      numerator += v * inv_distances[i]
    end
    ratio = numerator.to_f/inv_distances.sum
    if ratio.nan?  # return average if sum of inverse distances are 0
      return values.inject{ |sum, i| sum + i }.to_f / values.size
    else 
      return ratio 
    end
  end

# The number of records to use in each regression
RECORDS_PER_DAY = 3*6 #use data from last 3 hrs only
REGRESSION_RECORDS = 1*RECORDS_PER_DAY


# Get predictions for a particular lat/long pair for a certain time from now.
  def self.get_predictions lat, long, period
  
    nearby_locations = Location.get_nearest_locs(lat, long)
    p = Prediction.new(period.to_i) #check initialize of Prediction
    p.set_current_weather(nearby_locations)
    periods = (10..period.to_i).step(10).to_a # 0 is for current conditions
    
    break_out = false;
    MEASUREMENTS.each do |m|
        data = {}; data[m] = {}
        distances = []
        nearby_locations[0..1].each_with_index do |loc, i|
          if loc[:loc].last_update.nil? # if there is no data then no regression
            break_out = true
            break;
          end
          break if(break_out == true)
            records = Observation.where("location_id = ?",loc[:id]).last(REGRESSION_RECORDS)
            count = records.count
          	# if there are less than 2 records then no regression
          	if count < 2
          		break_out = true
          		break;
          	end
            epoch = records.first.unix_time
			# presumes time at start of day is 1 second (otherwise the values are too large)
            times_hack = periods.map{|x| count + (Time.zone.parse(p.data[x.to_s]["time"]) - epoch).to_i/10.0}
            # get data for each location (the data is hash with each period and r2)
            data[m][i] = Temperature.predict(Temperature.joins(:observation).where("observations.location_id = ?",loc[:id]).last(REGRESSION_RECORDS), times_hack, periods) if(m == "temp")
            data[m][i] = Rainfall.predict(Rainfall.joins(:observation).where("observations.location_id = ?",loc[:id]).last(REGRESSION_RECORDS), times_hack, periods) if(m == "rain")
      		data[m][i] = Wind.predict(Wind.joins(:observation).where("observations.location_id = ?",loc[:id]).last(REGRESSION_RECORDS), times_hack, periods, m)[:wind_speed] if (m == "wind_speed") 
      		data[m][i] = Wind.predict(Wind.joins(:observation).where("observations.location_id = ?",loc[:id]).last(REGRESSION_RECORDS), times_hack, periods, m)[:wind_direction] if (m == "wind_direction")
            distances << loc[:distance] # distances array for aggregation

            # add the data values to array for aggregation
            periods.each_with_index do |per|
                p.data[per.to_s][m]["value"] = [] if p.data[per.to_s][m]["value"].class != Array
                p.data[per.to_s][m]["value"] << data[m][i][per] if data[m][i] 
            end
        end
        break if(break_out == true)
        periods.each do |per|
            if p.data[per.to_s][m]["value"].compact.count != 2 # error checking
                p.data[per.to_s][m]["value"] = nil
                next
            end
            agg = Observation.aggregate(p.data[per.to_s][m]["value"], distances).round(2) #aggregate data for each period
            agg = agg.abs.to_s + "mm/h" if(m == "rain")
            agg = agg.abs.to_s + "km/h" if(m == "wind_speed")
            agg = Wind.bearing_to_cardinal(agg).to_s if (m == "wind_direction")
            agg = agg.to_s if (m == "temp")
            p.data[per.to_s][m]["value"] = agg
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
