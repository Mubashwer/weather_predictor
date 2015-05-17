require 'open-uri'

class Location < ActiveRecord::Base
    has_many :observations
	
	#Distance in Metres of "nearby stations"
	NEAR_DISTANCE = 1000000000000
    
    def as_json(options ={})
        my_hash = {"id" => station_id, "lat" => lat.to_s,
                   "lon" => lon.to_s,
                   "last_update" => last_update.strftime("%H:%M%P %d-%m-%Y")}
        return my_hash
    end

	def self.get_locs_by_postcode postcode
		return Location.where(postcode: postcode)
	end

	# haversine.rb  
	#  
	# haversine formula to compute the great circle distance between two points given their latitude and longitudes  
	#  
	# Copyright (C) 2008, 360VL, Inc  
	# Copyright (C) 2008, Landon Cox  
	#  
	# http://www.esawdust.com (Landon Cox)  
	# contact:  
	# http://www.esawdust.com/blog/businesscard/businesscard.html  
	#  
	# LICENSE: GNU Affero GPL v3  
	# The ruby implementation of the Haversine formula is free software: you can redistribute it and/or modify  
	# it under the terms of the GNU Affero General Public License version 3 as published by the Free Software Foundation.   
	#  
	# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the  
	# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public  
	# License version 3 for more details.  http://www.gnu.org/licenses/  
	#  
	# Landon Cox - 9/25/08  
	#  
	# Notes:  
	#  
	# translated into Ruby based on information contained in:  
	#   http://mathforum.org/library/drmath/view/51879.html  Doctors Rick and Peterson - 4/20/99  
	#   http://www.movable-type.co.uk/scripts/latlong.html  
	#   http://en.wikipedia.org/wiki/Haversine_formula  
	#  
	# This formula can compute accurate distances between two points given latitude and longitude, even for  
	# short distances.  
	   
	# PI = 3.1415926535  
	RAD_PER_DEG = 0.017453293  #  PI/180  
	  
	# the great circle distance d will be in whatever units R is in  
	  
	Rmiles = 3956           # radius of the great circle in miles  
	Rkm = 6371              # radius in kilometers...some algorithms use 6367  
	Rfeet = Rmiles * 5282   # radius in feet  
	Rmeters = Rkm * 1000    # radius in meters  
	  
	@distances = Hash.new   # this is global because if computing lots of track point distances, it didn't make  
	                        # sense to new a Hash each time over potentially 100's of thousands of points  
	  
	
	  
	def self.haversine_distance( lat1, lon1, lat2, lon2 )  
	  
	  dlon = lon2 - lon1  
	  dlat = lat2 - lat1  
	   
	  dlon_rad = dlon * RAD_PER_DEG  
	  dlat_rad = dlat * RAD_PER_DEG  
	   
	  lat1_rad = lat1 * RAD_PER_DEG  
	  lon1_rad = lon1 * RAD_PER_DEG  
	   
	  lat2_rad = lat2 * RAD_PER_DEG  
	  lon2_rad = lon2 * RAD_PER_DEG
	   
	  # puts "dlon: #{dlon}, dlon_rad: #{dlon_rad}, dlat: #{dlat}, dlat_rad: #{dlat_rad}"  
	   
	  a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2  
	  c = 2 * Math.asin( Math.sqrt(a))  
	   
	  dMi = Rmiles * c          # delta between the two points in miles  
	  dKm = Rkm * c             # delta in kilometers  
	  dFeet = Rfeet * c         # delta in feet  
	  dMeters = Rmeters * c     # delta in meters  
	   
	  @distances["mi"] = dMi  
	  @distances["km"] = dKm  
	  @distances["ft"] = dFeet  
	  @distances["m"] = dMeters 

	  return dMeters 
	end  
	  

	def self.find_sorted_weather_stations lat1, lon1, range


		distances = []

		Observation.all.each do |observation|
			lat = observation.location.lat
			lon = observation.location.lon
			distance = haversine_distance(lat1, lon1, lat, lon)
			if distance <= range
				distances << {id: observation.location.id, distance: distance}
			end
		end
		distances.sort{ |e1, e2| e1[:distance] <=> e2[:distance] }

		return distances
	end
	
	def self.get_nearest_locs lat, lon
		return find_sorted_weather_stations lat, lon, NEAR_DISTANCE
	end

	def test_haversine 
	   
	  lon1 = -104.88544  
	  lat1 = 39.06546  
	   
	  lon2 = -104.80  
	  lat2 = lat1  
	   
	  haversine_distance( lat1, lon1, lat2, lon2 )  
	   
	  puts "the distance from  #{lat1}, #{lon1} to #{lat2}, #{lon2} is:"  
	  puts "#{@distances['mi']} mi"  
	  puts "#{@distances['km']} km"  
	  puts "#{@distances['ft']} ft"  
	  puts "#{@distances['m']} m"  
	   
	  if @distances['km'].to_s =~ /7\.376*/  
	    puts "Test: Success"  
	  else  
	    puts "Test: Failed"  
	  end  
	   

	end  
	  



	def self.get_lat_long postcode
		url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{postcode}&components=country:AU"
		doc = JSON.parse(open(url).read)
   	
		if (doc["status"] == "OK") 
			latitude = doc["results"][0]["geometry"]["location"]["lat"]
    		longtitude = doc["results"][0]["geometry"]["location"]["lng"]
    	else
   		
   			raise "Error parsing data"
		end
		return [latitude, longtitude]
	
	end   

end
