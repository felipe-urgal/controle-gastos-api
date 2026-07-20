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
      evolution: evolution,
      topCategories: top_categories,
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

  def evolution
    months = (0..5).map { |offset| Date.new(year, month, 1) << offset }.reverse

    months.map do |date|
      scope = user.transactions.completed.where(year: date.year, month: date.month)

      {
        year: date.year,
        month: date.month,
        income: scope.income.sum(:amount),
        expense: scope.expense.sum(:amount)
      }
    end
  end

  def top_categories
    totals = month_transactions.expense
      .group(:category_id)
      .sum(:amount)
      .sort_by { |_category_id, total| -total }
      .first(5)

    categories = Category.where(id: totals.map(&:first)).index_by(&:id)

    totals.map do |category_id, total|
      category = categories[category_id]

      { categoryId: category_id, name: category.name, icon: category.icon, color: category.color, total: total }
    end
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
