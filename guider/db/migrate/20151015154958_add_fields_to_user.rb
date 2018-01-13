class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :is_guide, :boolean
    add_column :users, :lang_array, :text, array: true, default: []
  end
end
