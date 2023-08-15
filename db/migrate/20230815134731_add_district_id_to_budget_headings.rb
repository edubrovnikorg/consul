class AddDistrictIdToBudgetHeadings < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_headings, :budget_id, :integer
    add_column :budget_headings, :district_id, :integer

    add_index  :budget_headings, :budget_id
    add_index  :budget_headings, :district_id
  end
end
