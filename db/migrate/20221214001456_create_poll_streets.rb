class CreatePollStreets < ActiveRecord::Migration[5.2]
  def change
    create_table :streets do |t|
      t.string :name
      t.string :county

      t.timestamps
    end

    create_table :poll_streets, id: false do |t|
      t.belongs_to :polls
      t.belongs_to :streets
    end
  end
end
