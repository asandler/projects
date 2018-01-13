class AddDescriptionAndDatesAndMaxPeopleToRoutes < ActiveRecord::Migration
  def change
    add_column :routes, :date_array, :text, array: true, default: []
    add_column :routes, :description, :string
    add_column :routes, :max_people, :integer, default: 0
  end
end
