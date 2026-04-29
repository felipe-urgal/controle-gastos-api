class UserSerializer
  def self.call(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      showValues: user.show_values,
      createdAt: user.created_at&.iso8601,
      updatedAt: user.updated_at&.iso8601
    }
  end
end
