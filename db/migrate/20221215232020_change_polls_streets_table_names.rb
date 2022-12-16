class ChangePollsStreetsTableNames < ActiveRecord::Migration[5.2]
  def change
    rename_column :polls_streets, :polls_id, :poll_id
    rename_column :polls_streets, :streets_id, :street_id
  end
end
