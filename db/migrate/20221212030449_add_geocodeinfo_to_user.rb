class AddGeocodeinfoToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :geo_data, :text
  end
end
