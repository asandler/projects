class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :email, uniqueness: true
  validates :password, length: { minimum: 6 }

  has_many :documents, dependent: :destroy
  has_many :folders, dependent: :destroy
end
