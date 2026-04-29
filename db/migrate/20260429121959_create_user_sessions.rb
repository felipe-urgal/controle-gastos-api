class CreateUserSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :user_sessions, id: :uuid do |t|
      t.references :user, null: false, type: :uuid, foreign_key: { on_delete: :cascade }
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.datetime :last_used_at

      t.timestamps
    end

    add_index :user_sessions, :token_digest, unique: true
    add_index :user_sessions, :expires_at
    add_index :user_sessions, :revoked_at
  end
end
