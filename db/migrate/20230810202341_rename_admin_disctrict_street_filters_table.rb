class RenameAdminDisctrictStreetFiltersTable < ActiveRecord::Migration[5.2]
  def change
    rename_table :admin_district_street_filters, :district_street_filters
  end
end
