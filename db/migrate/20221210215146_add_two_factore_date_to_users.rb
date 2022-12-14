class AddTwoFactoreDateToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :two_factor_date, :datetime
  end
end
