class AddDistrictStreetFiltersTable < ActiveRecord::Migration[5.2]
  def change
    create_table :district_street_filters do |t|
      t.references :district_street, foreign_key: true
      t.integer :from
      t.integer :to

      t.timestamps
    end
  end
end
