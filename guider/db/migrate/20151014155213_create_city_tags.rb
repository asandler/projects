class CreateCityTags < ActiveRecord::Migration
  def change
    create_table :city_tags do |t|
      t.string :value

      t.timestamps null: false
    end
  end
end
