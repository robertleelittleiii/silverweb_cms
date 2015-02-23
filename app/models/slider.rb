class Slider < ActiveRecord::Base
  belongs_to :page
  
  
  scope :active, -> { where(slider_active: true).order('slider_order desc')}

end
