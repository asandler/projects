class Route < ActiveRecord::Base
  belongs_to :city
  belongs_to :user
  validates :city_id, :name, :price, :hours, :minutes, presence: true

  has_many :route_photos, :dependent => :destroy
  #accepts_nested_attributes_for :route_photos, :reject_if => lambda { |t| t['route_photo'].nil? }
end
