class CreateWinds < ActiveRecord::Migration
  def change
    create_table :winds do |t|
      t.float :speed
      t.integer :bearing
      t.references :observation, index: true

      t.timestamps
    end
  end
end
