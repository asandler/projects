class RoutePhoto < ActiveRecord::Base
    belongs_to :route
    has_attached_file :photo, :styles => {:medium => "300x300>"}
    validates_attachment_presence :photo
    validates_attachment_size :photo, :less_than => 5.megabytes
    validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
