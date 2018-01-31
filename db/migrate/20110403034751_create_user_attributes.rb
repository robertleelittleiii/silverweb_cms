class CreateUserAttributes < ActiveRecord::Migration[5.0]
  def self.up
    create_table :user_attributes do |t|
      t.string :first_name
      t.string :last_name
      t.string :handle
      t.date :birthdate
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :user_attributes
  end
end
