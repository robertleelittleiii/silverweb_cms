class CreateUserLiveEdits < ActiveRecord::Migration
  def self.up
    if not ActiveRecord::Base.connection.table_exists? 'user_live_editsÏ' then
      create_table :user_live_edits do |t|
        t.integer :user_id
        t.string :current_type
        t.string :current_action
        t.integer :current_idÏ
        t.string :current_field

        t.timestamps
      end
    end
  end

  def self.down
    if  ActiveRecord::Base.connection.table_exists? 'user_live_edits' then
      drop_table :user_live_edits
    end
  end
end
