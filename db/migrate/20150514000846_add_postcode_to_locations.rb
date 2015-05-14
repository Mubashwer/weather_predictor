class AddPostcodeToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :postcode, :string
  end
end
