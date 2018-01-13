class RemoveRegular < ActiveRecord::Migration
  def change
    remove_column :routes, :regular
  end
end
