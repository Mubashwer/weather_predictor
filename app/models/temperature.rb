class Temperature < ActiveRecord::Base
  belongs_to :observation

  # change if need be
  def self.predict temp_set, times, periods
  	data = nil
  	if temp_set
  		epoch = Temperature.first.unix_time + 1
  		times.each do |time|
	  		begin
	  		predictions = Regression.get_value(temp_set.map{|t| t.unix_time - epoch}, temp_set.map{|t| t.temp}, times)
	  		rescue
	  		predictions = nil
	  		end
	  		data = {}
	  		periods.each_with_index do |p, i|
	  			data[p] = predictions[:value][i]
	  		end
	  		data[:r2] = predictions[:r2]
	  	end
  	end
  	return data
  end
end
