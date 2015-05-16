class AddUnixTimeToTemperatures < ActiveRecord::Migration
  def change
    add_column :temperatures, :unix_time, :integer
  end
end
