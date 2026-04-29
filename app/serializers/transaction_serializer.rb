class TransactionSerializer
  def self.call(transaction)
    {
      id: transaction.id,
      amount: transaction.amount,
      type: transaction.transaction_type.to_s.upcase,
      description: transaction.description,
      status: transaction.status.to_s.upcase,
      year: transaction.year,
      month: transaction.month,
      day: transaction.day,

      account: {
        id: transaction.account.id,
        name: transaction.account.name,
        currency: transaction.account.currency,
        type: transaction.account.account_type.to_s.upcase,
        color: transaction.account.color,
        icon: transaction.account.icon
      },

      category: {
        id: transaction.category.id,
        name: transaction.category.name,
        type: transaction.category.category_type.to_s.upcase,
        color: transaction.category.color,
        icon: transaction.category.icon
      },

      createdAt: transaction.created_at.iso8601,
      updatedAt: transaction.updated_at.iso8601
    }
  end
end
