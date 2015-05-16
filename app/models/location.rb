class Location < ActiveRecord::Base
    has_many :observations
    
    def as_json(options ={})
        my_hash = {"id" => station_id, "lat" => lat.to_s,
                   "lon" => lon.to_s,
                   "last_update" => last_update.strftime("%H:%M%P %d-%m-%Y")}
        return my_hash
    end
end
