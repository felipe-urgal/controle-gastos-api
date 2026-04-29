class CategorySerializer
  def self.call(category)
    {
      id: category.id,
      name: category.name,
      color: category.color,
      icon: category.icon,
      isActive: category.is_active,
      type: category.category_type.upcase,
      description: category.description,
      position: category.position,
      createdAt: category.created_at&.iso8601,
      updatedAt: category.updated_at&.iso8601
    }
  end
end
