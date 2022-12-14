class AddTwoFactoreCodeToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :two_factor_code, :string
  end
end
