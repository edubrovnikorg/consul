class CreateAdminBudgetsImages < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_images do |t|
      t.string :description

      t.timestamps
    end
  end
end
