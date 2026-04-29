class Category < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :restrict_with_error

  enum :category_type, {
    income: 0,
    expense: 1
  }, prefix: true

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :color, presence: true, format: { with: /\A#[0-9A-Fa-f]{6}\z/ }
  validates :icon, presence: true, length: { maximum: 30 }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :category_type, presence: true

  validates :name, uniqueness: { scope: [:user_id, :category_type] }

  scope :active, -> { where(is_active: true) }
end
