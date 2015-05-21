module WeatherHelper
	def pretty_generate myhash
		return JSON.pretty_generate(myhash).gsub(/^/, '  ')[1..-1].html_safe
	end

	def current_date
		return Time.zone.now.strftime("%d-%m-%Y")
	end
end
