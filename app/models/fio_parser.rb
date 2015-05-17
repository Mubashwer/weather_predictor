require 'json'
require 'open-uri'

class Fio_parser
    
    API_KEYS = ['1c51183d2b5f1519197199775b62a651']
    BASE_URL = 'https://api.forecast.io/forecast'
    UNITS = 'units=ca' # gives values in SI units, and wind speed in km/h
    EXCLUDE = 'exclude=minutely,hourly,daily,alerts,flags' # excludes unnecessary data
    @@key_index = 0
    include ActiveModel::Model
    
    # this parses data from ForecastIO AND persists it into the database
    def self.parse
        Location.all.each do |loc|
            lat_long =  loc.lat.to_s + "," + loc.lon.to_s
            api_key = self.get_api_key
            data =  JSON.parse(open("#{BASE_URL}/#{api_key}/#{lat_long}?#{UNITS}&#{EXCLUDE}").read)["currently"]
            obs = loc.observations.create(condition: data["summary"], unix_time: data["time"])
            obs.create_rainfall(intensity: data["precipIntensity"], unix_time: data["time"])
            obs.create_wind(speed: data["windSpeed"], bearing: data["windBearing"], unix_time: data["time"])
            obs.create_temperature(temp: data["temperature"], unix_time: data["time"])
        end
    end

    # this gets the api_key from API_KEYS and moves to the next key for next call
    def self.get_api_key
        api_key = API_KEYS[@@key_index]
        @@key_index += 1
        @@key_index = 0 if @@key_index >= API_KEYS.count
        return api_key
    end
    
end