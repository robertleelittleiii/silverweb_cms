# db/migrate/YYYYMMDDHHMMSS_add_authpoint_fields_to_users.rb
class AddAuthpointSessionIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :authpoint_session_id, :string
    add_index :users, :authpoint_session_id
  end
end
