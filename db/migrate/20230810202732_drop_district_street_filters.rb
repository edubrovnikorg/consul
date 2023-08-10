class DropDistrictStreetFilters < ActiveRecord::Migration[5.2]
  def change
    drop_table :district_street_filters
  end
end
