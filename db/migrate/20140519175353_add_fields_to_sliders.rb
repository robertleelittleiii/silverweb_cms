class AddFieldsToSliders < ActiveRecord::Migration[5.0]
  def self.up
    add_column :sliders, :slider_url, :string
    add_column :sliders, :slider_tag_line_one, :string
    add_column :sliders, :slider_tag_line_two, :string
    add_column :sliders, :slider_button_color, :string
  end

  def self.down
    remove_column :sliders, :slider_button_color
    remove_column :sliders, :slider_tag_line_two
    remove_column :sliders, :slider_tag_line_one
    remove_column :sliders, :slider_url
  end
end
