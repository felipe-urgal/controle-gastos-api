class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions, id: :uuid do |t|
      t.integer :amount, null: false, default: 0

      t.integer :year, null: false
      t.integer :month, null: false
      t.integer :day, null: false

      t.string :transaction_type, null: false
      t.string :status, null: false, default: "COMPLETED"

      t.string :description, null: false, limit: 255

      t.references :account, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.references :category, null: false, type: :uuid, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :transactions, [:user_id, :year, :month]
    add_index :transactions, [:user_id, :year, :month, :day]
    add_index :transactions, [:account_id, :year, :month]
    add_index :transactions, [:user_id, :category_id, :year, :month]
    add_index :transactions, [:account_id, :transaction_type, :year, :month]
  end
end
