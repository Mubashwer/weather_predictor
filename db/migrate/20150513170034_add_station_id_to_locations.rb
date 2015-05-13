class AddStationIdToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :station_id, :string
  end
end
