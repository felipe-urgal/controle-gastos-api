class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts, id: :uuid do |t|
      t.string :name, null: false, limit: 100
      t.integer :account_type, null: false
      t.integer :balance, null: false, default: 0
      t.string :currency, null: false, limit: 3, default: "BRL"
      t.boolean :is_active, null: false, default: true
      t.string :color, limit: 7
      t.string :icon, limit: 30
      t.string :description, limit: 500

      t.references :user, null: false, type: :uuid, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :accounts, [:name, :user_id], unique: true
    add_index :accounts, [:user_id, :account_type]
    add_index :accounts, [:user_id, :is_active]
    add_index :accounts, [:user_id, :currency, :is_active]
  end
end
