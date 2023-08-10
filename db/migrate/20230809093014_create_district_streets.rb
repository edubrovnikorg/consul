class CreateDistrictStreets < ActiveRecord::Migration[5.2]
  def change
    create_table :district_streets do |t|
      t.references :district, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
