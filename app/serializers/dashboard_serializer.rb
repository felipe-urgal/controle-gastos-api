class DashboardSerializer
  def self.call(user, year:, month:)
    new(user, year, month).call
  end

  def initialize(user, year, month)
    @user = user
    @year = year
    @month = month
  end

  def call
    {
      summary: summary,
      evolution: [],
      topCategories: [],
      accounts: accounts,
      recentTransactions: recent_transactions
    }
  end

  private

  attr_reader :user, :year, :month

  def month_transactions
    user.transactions.completed.where(year: year, month: month)
  end

  def summary
    income = month_transactions.income.sum(:amount)
    expense = month_transactions.expense.sum(:amount)

    { year: year, month: month, income: income, expense: expense, balance: income - expense }
  end

  def accounts
    user.accounts.active.map do |account|
      {
        id: account.id,
        name: account.name,
        balance: account.balance,
        currency: account.currency,
        color: account.color,
        icon: account.icon
      }
    end
  end

  def recent_transactions
    user.transactions.order(created_at: :desc).limit(5).map { |t| TransactionSerializer.call(t) }
  end
end
