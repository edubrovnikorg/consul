class AddBudgetDescriptionTranslation < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_translations, :description_text, :text
  end
end
