class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy

  enum :account_type, {
    credit_debit: 0,
    investment: 1
  }, prefix: true

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :currency, presence: true, length: { is: 3 }
  validates :account_type, presence: true
  validates :balance, presence: true, numericality: { only_integer: true }

  validates :name, uniqueness: { scope: :user_id }

  scope :active, -> { where(is_active: true) }

  before_validation :normalize_currency

  def recalculate_balance!
    income = transactions
      .completed
      .income
      .sum(:amount)

    expense = transactions
      .completed
      .expense
      .sum(:amount)

    update_column(:balance, income - expense)
  end

  private

  def normalize_currency
    self.currency = currency.to_s.upcase if currency.present?
  end
end
