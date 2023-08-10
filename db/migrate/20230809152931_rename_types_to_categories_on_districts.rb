class RenameTypesToCategoriesOnDistricts < ActiveRecord::Migration[5.2]
  def change
    rename_column :districts, :type, :category
  end
end
