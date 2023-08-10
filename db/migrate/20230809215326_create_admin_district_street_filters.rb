class CreateAdminDistrictStreetFilters < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_district_street_filters do |t|
      t.references :district_streets, foreign_key: true
      t.integer :from
      t.integer :to

      t.timestamps
    end
  end
end
