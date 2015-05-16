class CreateRainfalls < ActiveRecord::Migration
  def change
    create_table :rainfalls do |t|
      t.float :intensity
      t.references :observation, index: true

      t.timestamps
    end
  end
end
