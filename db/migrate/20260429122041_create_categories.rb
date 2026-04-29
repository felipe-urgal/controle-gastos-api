class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories, id: :uuid do |t|
      t.string :name, null: false, limit: 50
      t.string :color, null: false, limit: 7, default: "#3B82F6"
      t.string :icon, null: false, limit: 30, default: "tag"
      t.boolean :is_active, null: false, default: true
      t.integer :category_type, null: false, default: 1 # expense
      t.string :description, limit: 255
      t.integer :position, null: false, default: 0

      t.references :user, null: false, type: :uuid, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :categories, [:name, :user_id, :category_type], unique: true
    add_index :categories, [:user_id, :category_type, :is_active]
    add_index :categories, [:user_id, :position]
  end
end
