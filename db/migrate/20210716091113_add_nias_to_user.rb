class AddNiasToUser < ActiveRecord::Migration[5.2]
  def self.up
    add_column :users, :ime, :string, :default => false, :null => true
    add_column :users, :prezime, :string, :default => false, :null => true
    add_column :users, :oib, :bigint, :default => false, :null => true
    add_column :users, :tid, :bigint, :default => false, :null => true
    add_column :users, :subject_id_format, :string, :default => false, :null => true
    add_column :users, :session_index, :string, :default => false, :null => true
    add_column :users, :subject_id, :string, :default => false, :null => true
    
    add_index  :users, :oib
  end

  def self.down
    remove_index  :users, :oib
    remove_column :users, :ime
    remove_column :users, :prezime
    remove_column :users, :oib
    remove_column :users, :tid
    remove_column :users, :subject_id_format
    remove_column :users, :session_index
    remove_column :users, :subject_id
  end
end
