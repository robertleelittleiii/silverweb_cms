class AddDialogwidthAndHeightToPages < ActiveRecord::Migration[5.0]
  def self.up
    add_column :pages, :dialog_width, :integer
    add_column :pages, :dialog_height, :integer
  end

  def self.down
    remove_column :pages, :dialog_height
    remove_column :pages, :dialog_width
  end
end
