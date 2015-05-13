class AddLastUpdateToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :last_update, :datetime
  end
end
