class Rainfall < ActiveRecord::Base
  belongs_to :observation

  # change if need be
  def self.predict rain_set, times, periods
  	data = nil
  	if rain_set
  		epoch = rain_set.first.unix_time + 1
  		begin
  		predictions = Regression.get_value(rain_set.map{|r| r.unix_time - epoch}, rain_set.map{|r| r.intensity}, times)
  		rescue
  		predictions = {value: periods.map{|x| 0.0},r2: 0.0}
  		end
  		data = {}
  		periods.each_with_index do |p, i|
  			data[p] = predictions[:value][i]
  		end
  		data[:r2] = predictions[:r2]
  	end
  	return data
  end
end
