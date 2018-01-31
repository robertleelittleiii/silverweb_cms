class CreateSettingsTable < ActiveRecord::Migration[5.0]
  def self.up
    if not ActiveRecord::Base.connection.table_exists? 'settings' then
      create_table :settings, :force => true do |t|
        t.string  :var,         :null => false
        t.text    :value
        t.integer :target_id
        t.string  :target_type, :limit => 30
        t.timestamps
      end
   
      add_index :settings, [ :target_type, :target_id, :var ], :unique => true

    end

  end

  def self.down
    if ActiveRecord::Base.connection.table_exists? 'settings' then

      drop_table :settings
    end
  end
end
