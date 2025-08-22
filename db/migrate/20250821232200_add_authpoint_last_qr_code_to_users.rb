class AddAuthpointLastQrCodeToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :authpoint_last_qr_code, :text
  end
end
