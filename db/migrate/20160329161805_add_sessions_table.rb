class AddSessionsTable < ActiveRecord::Migration[5.0]
  
  def change
    if not ActiveRecord::Base.connection.table_exists? 'sessions' then

      create_table :sessions do |t|
        t.string :session_id, :null => false
        t.text :data
        t.timestamps
      end

      add_index :sessions, :session_id, :unique => true
      add_index :sessions, :updated_at
    
    end
  end
end
