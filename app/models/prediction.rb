class Prediction
    include ActiveModel::Model
    attr_accessor :data
	
	def initialize
		data = {}
	end
	
    # this parses data from ForecastIO AND persists it into the database
    def get_data
        return data
    end
    
end