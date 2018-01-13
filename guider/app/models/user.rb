def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    ResetPasswordMailer.password_reset(self).deliver
end

def generate_token(column)
    begin
        self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
end

class User < ActiveRecord::Base
  has_many :routes
  before_create { generate_token(:auth_token) }

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end

  has_many :authentications, :dependent => :destroy
  accepts_nested_attributes_for :authentications

  has_attached_file :avatar, styles: { medium: "300x300>", thumb: "100x100>", little: "50x50>" }, default_url: "/images/:style/missing.png"
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/
end
