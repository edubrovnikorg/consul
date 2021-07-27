class AddLogoutIdentifiers < ActiveRecord::Migration[5.2]
  def self.up
    add_column :users, :logout_request_id, :string, :default => false, :null => true
    
    add_index  :users, :subject_id_format
    add_index  :users, :session_index
    add_index  :users, :logout_request_id
  end

  def self.down
    remove_index  :users, :subject_id_format
    remove_index  :users, :session_index
    remove_index  :users, :logout_request_id

    remove_column :users, :logout_request_id
  end
end
