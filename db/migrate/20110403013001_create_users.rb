class CreateUsers < ActiveRecord::Migration
    def self.up
    create_table :users do |t|
      t.string :name
      t.string :hashed_password
      t.string :salt
      t.string :remember_token
      t.datetime :remember_token_expires_at
      t.string :activation_code, limit: 40
      t.datetime :activated_at
      t.string :state, null: :no, default: 'passive'
      t.datetime :deleted_at
      t.string :password_reset_code, limit: 40
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
