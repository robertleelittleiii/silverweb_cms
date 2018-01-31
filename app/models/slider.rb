class Slider < ActiveRecord::Base
  belongs_to :page, optional: true
  
  
  scope :active, -> { where(slider_active: true).order('slider_order desc')}

end
