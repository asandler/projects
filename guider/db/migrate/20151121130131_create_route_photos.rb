class CreateRoutePhotos < ActiveRecord::Migration
  def change
    create_table :route_photos do |t|
      t.string :description

      t.timestamps null: false
    end
  end
end
