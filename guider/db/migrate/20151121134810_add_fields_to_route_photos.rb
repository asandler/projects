class AddFieldsToRoutePhotos < ActiveRecord::Migration
  def change
    add_column :route_photos, :photo_file_name, :string # Original filename
    add_column :route_photos, :photo_content_type, :string # Mime type
    add_column :route_photos, :photo_file_size, :integer # File size in bytes
  end
end
