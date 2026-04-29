class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :account
  belongs_to :category

  enum :transaction_type, {
    income: "INCOME",
    expense: "EXPENSE"
  }, prefix: true

  enum :status, {
    pending: "PENDING",
    completed: "COMPLETED",
    cancelled: "CANCELLED"
  }, prefix: true

  validates :amount,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0,
              less_than_or_equal_to: 1_000_000_000
            }

  validates :description,
            presence: true,
            length: { minimum: 2, maximum: 100 }

  validates :year,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 2000,
              less_than_or_equal_to: 2100
            }

  validates :month,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 12
            }

  validates :day,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 31
            }

  validates :transaction_type, presence: true
  validates :status, presence: true

  scope :completed, -> { where(status: :completed) }
  scope :income, -> { where(transaction_type: :income) }
  scope :expense, -> { where(transaction_type: :expense) }
end
