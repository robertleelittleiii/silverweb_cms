class CreateUserLiveEdits < ActiveRecord::Migration
  def self.up
    create_table :user_live_edits do |t|
      t.integer :user_id
      t.string :current_type
      t.string :current_action
      t.integer :current_id
      t.string :current_field

      t.timestamps
    end
  end

  def self.down
    drop_table :user_live_edits
  end
end
