class AddMultiFactorTypeToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :multi_factor_type, :string
  end
end
