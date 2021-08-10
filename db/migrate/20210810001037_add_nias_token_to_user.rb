class AddNiasTokenToUser < ActiveRecord::Migration[5.2]
   def self.up
    add_column :users, :nias_token, :string, :default => false, :null => true
    add_index  :users, :nias_token
  end

  def self.down
    remove_index  :users, :nias_token
    remove_column :users, :nias_token
  end
end
