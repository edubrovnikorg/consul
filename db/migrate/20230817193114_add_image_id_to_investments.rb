class AddImageIdToInvestments < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_investments, :image_id, :integer
  end
end
