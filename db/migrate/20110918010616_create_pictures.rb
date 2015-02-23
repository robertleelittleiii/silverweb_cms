class CreatePictures < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.string :title
      t.text :description
      t.integer :position
      t.string :image
      t.integer :resource_id
      t.string :resource_type
      t.timestamps
    end
  end

  def self.down
    drop_table :pictures
  end
end
