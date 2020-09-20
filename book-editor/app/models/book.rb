class Book < ActiveRecord::Base
    has_many :pages, dependent: :destroy
    validates :title, presence: true
    has_and_belongs_to_many :users
end
