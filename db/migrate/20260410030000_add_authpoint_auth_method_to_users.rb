class AddAuthpointAuthMethodToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :authpoint_auth_method, :string
  end
end
