class CreatePages < ActiveRecord::Migration[5.0]
  def self.up
    create_table :pages do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
