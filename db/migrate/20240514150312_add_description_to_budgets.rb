class AddDescriptionToBudgets < ActiveRecord::Migration[5.2]
  def change
    add_column :budgets, :description_text, :text
  end
end
