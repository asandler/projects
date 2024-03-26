class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :email, uniqueness: true
  validates :password, length: { minimum: 6 }
end
