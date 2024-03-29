class Temperature < ActiveRecord::Base
  belongs_to :observation

  # change if need be
  def self.predict temp_set, times, periods
  	data = nil
  	if temp_set
  		epoch = temp_set.first.unix_time + 1
  		begin
  		predictions = Regression.get_value(temp_set.map{|t| t.unix_time - epoch}, temp_set.map{|t| t.temp}, times)
  		rescue
  		predictions = nil
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
