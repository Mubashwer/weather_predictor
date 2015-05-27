class Prediction
    MEASUREMENTS = ["rain", "temp", "wind_speed", "wind_direction"]
    attr_accessor :data # use this to change the values and probabilities
    include ActiveModel::Model
    
    # initializes prediction hash... 
    def initialize(period=10)
        @data = {}
        prediction_time = Time.zone.now
        (0..period).step(10) do |p|
            @data[p.to_s] = {}
            @data[p.to_s]["time"] = prediction_time.strftime("%H:%M%P %d-%m-%Y")
            prediction_time += 10.minutes
            MEASUREMENTS.each do |m|
                @data[p.to_s][m] = {}
                @data[p.to_s][m]["value"] = "null"
                @data[p.to_s][m]["probability"] = "null"
            end
        end

    end

    # takes nearby locations and aggregates current weather values
    def set_current_weather(locations)
        lower_bound = Time.zone.now - 30.minutes
        loc_ids = []; distances = []
        locations.each do |loc, i|
            if loc[:loc].last_update > lower_bound
                loc_ids << loc[:id]
                distances << loc[:distance]
            end
        end
        loc_ids = loc_ids[0..1]; distances = distances[0..1]
        return if !loc_ids.compact.any?
        MEASUREMENTS.each do |m|
            values = []
            loc_ids.each do |lid|
                obs = Observation.where(location_id: lid).last
                values << obs.rainfall.intensity if (m == "rain")
                values << obs.temperature.temp if (m == "temp")
                values << obs.wind.speed if (m == "wind_speed")
                values << obs.wind.bearing if (m == "wind_direction")
            end
            agg = Observation.aggregate(values, distances).round(2)
            agg = agg.abs.to_s + "mm/h" if(m == "rain")
            agg = agg.abs.to_s + "km/h" if(m == "wind_speed")
            agg = Wind.bearing_to_cardinal(agg).to_s if (m == "wind_direction")
            agg = agg.to_s if (m == "temp")
            @data["0"][m]["value"] = agg
            @data["0"][m]["probability"] = "1"

        end
    end
end