class AddUnixTimeToWinds < ActiveRecord::Migration
  def change
    add_column :winds, :unix_time, :integer
  end
end
