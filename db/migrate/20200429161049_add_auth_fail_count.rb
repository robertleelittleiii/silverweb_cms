class AddAuthFailCount < ActiveRecord::Migration[5.1]
  def change
        add_column :users, :auth_fail_count, :integer
  end
end
