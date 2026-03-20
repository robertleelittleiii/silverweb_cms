class AddAllowTextMessagesToUserAttributes < ActiveRecord::Migration[6.1]
  def change
    add_column :user_attributes, :allow_text_messages, :boolean, default: false
  end
end
