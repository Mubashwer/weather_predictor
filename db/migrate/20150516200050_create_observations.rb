class CreateObservations < ActiveRecord::Migration
  def change
    create_table :observations do |t|
      t.string :condition
      t.integer :unix_time
      t.references :location, index: true

      t.timestamps
    end
  end
end
