class AddUnixTimeToRainfalls < ActiveRecord::Migration
  def change
    add_column :rainfalls, :unix_time, :integer
  end
end
