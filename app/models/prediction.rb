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

end