class RenamePollStreetsToPollsStreets < ActiveRecord::Migration[5.2]
  def change
    rename_table :poll_streets, :polls_streets
  end
end
