require 'json'
require 'open-uri'

class Fio_parser
    
    API_KEYS = ['1c51183d2b5f1519197199775b62a651','fb5456e612f49314454654915f6e14f1',
                '15d60298255e2dfb97ecc14171b1a16f' ,'ed7d0fa03028192be9cf229b52c67443', 
                '4b37bddfe271d073ec33ef6678638dc1','f3ede70cbe79415dea74ed6005f68046',
                'ad69b53afdb626dcbd4f8ec76c06d775', '50734796b20e6ef4dbbdccc85ca32b81',
                '00f4102070a186375bdd50ca41656fab','697c52379297ff535f004dffc346849a',
                'c5b96b8019dc0eb9a7abca294435d6d7', '6250efcf0b6f2faead2be6305932383f',
                'ba51320f3b48cd1f45222b6f053e089c', '1a03c3b5d1a894809c6e04603ca33256',
				'deba5387e6833339e131f6b16a7816f5', 'b03b7f2c72ddfea9b80b0db88e092619',
				'a25b360d429cd8dcec750f4299daad57', '9d04ab701e613ebf58c9c1deacd13fd3',
				'c961a28b29b9024fc7fbd483218b5f33', 'de2b379499cb544b85743a5a2f348f22']
    
    BASE_URL = 'https://api.forecast.io/forecast'
    UNITS = 'units=ca' # gives values in SI units, and wind speed in km/h
    EXCLUDE = 'exclude=minutely,hourly,daily,alerts,flags' # excludes unnecessary data
    @@key_index = 0
    include ActiveModel::Model
    
    # this parses data from ForecastIO AND persists it into the database
    def self.parse
        Location.all.each do |loc|
            lat_long =  loc.lat.to_s + "," + loc.lon.to_s
            api_key = get_api_key
            data =  JSON.parse(open("#{BASE_URL}/#{api_key}/#{lat_long}?#{UNITS}&#{EXCLUDE}").read)["currently"]
            obs = loc.observations.create(condition: data["summary"], unix_time: data["time"])
            obs.create_rainfall(intensity: data["precipIntensity"], unix_time: data["time"])
            obs.create_wind(speed: data["windSpeed"], bearing: data["windBearing"], unix_time: data["time"])
            obs.create_temperature(temp: data["temperature"], unix_time: data["time"])
            loc.last_update = Time.now.to_datetime
            loc.save
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