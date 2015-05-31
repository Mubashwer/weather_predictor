class LocationController < ApplicationController
  
  def locations
    @locations = Location.all
  end
  
end
