class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.references :city, index: true, foreign_key: true
      t.integer :price
      t.integer :hours
      t.integer :minutes
      t.boolean :regular
      t.text :city_tags, array: true, default: []

      t.timestamps null: false
    end
  end
end
