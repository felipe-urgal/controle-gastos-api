class AccountSerializer
  def self.call(account)
    {
      id: account.id,
      name: account.name,
      type: account.account_type.upcase,
      balance: account.balance,
      currency: account.currency,
      isActive: account.is_active,
      color: account.color,
      icon: account.icon,
      description: account.description,
      createdAt: account.created_at&.iso8601,
      updatedAt: account.updated_at&.iso8601
    }
  end
end
