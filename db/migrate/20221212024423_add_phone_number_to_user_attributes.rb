class AddPhoneNumberToUserAttributes < ActiveRecord::Migration[6.1]
  def change
    add_column :user_attributes, :phone_number, :string
  end
end
