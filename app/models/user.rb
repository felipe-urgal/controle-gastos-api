# app/models/user.rb
class User < ApplicationRecord
  has_secure_password

  has_many :user_sessions, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :categories, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: true, length: { maximum: 120 }

  before_validation :normalize_email

  private

  def normalize_email
    self.email = email.to_s.strip.downcase if email.present?
  end
end
