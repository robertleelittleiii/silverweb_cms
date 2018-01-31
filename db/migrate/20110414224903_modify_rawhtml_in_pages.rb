class ModifyRawhtmlInPages < ActiveRecord::Migration[5.0]
   def self.up
    change_column :menus, :rawhtml, :text;
  end

  def self.down
     change_column :menus, :rawhtml, :string, limit: 300;
 end
end
