class CreateWebauthnCredentials < ActiveRecord::Migration[7.2]
  def change
    create_table :webauthn_credentials, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :external_id, null: false       # the credential ID (b64url)
      t.text :public_key, null: false          # COSE public key (b64)
      t.bigint :sign_count, null: false, default: 0
      t.string :nickname                        # user-friendly label
      t.datetime :last_used_at
      t.timestamps
    end

    add_index :webauthn_credentials, :external_id, unique: true

    # Per-user webauthn_id used by libraries to associate credentials with users
    add_column :users, :webauthn_id, :string
    add_index :users, :webauthn_id, unique: true
  end
end
