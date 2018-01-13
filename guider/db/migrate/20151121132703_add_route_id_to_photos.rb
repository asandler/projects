class AddRouteIdToPhotos < ActiveRecord::Migration
  def change
    add_reference :route_photos, :route, index: true, foreign_key: true
  end
end
