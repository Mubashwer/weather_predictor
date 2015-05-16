class CreateTemperatures < ActiveRecord::Migration
  def change
    create_table :temperatures do |t|
      t.float :temp
      t.references :observation, index: true

      t.timestamps
    end
  end
end
