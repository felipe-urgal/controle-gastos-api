class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name, null: false, limit: 100
      t.string :email, null: false, limit: 120
      t.string :password_digest, null: false, limit: 255
      t.datetime :last_login
      t.boolean :is_active, null: false, default: true
      t.boolean :show_values, null: false, default: true

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :last_login
    add_index :users, [:created_at, :is_active]
  end
end
