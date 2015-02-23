class TinyPrint < ActiveRecord::Base
  
  has_attached_file :image,
    :convert_options => { :quality =>  4 },
    :styles => { :small_thumb => [ "50x50", :jpg ],
	               :medium_thumb => [ "100x100", :jpg ],
                 :large_thumb => [ "370x370", :jpg ],
	               :detail_preview => [ "450x338", :jpg ],
                 :slider_large => ["720x500", :jpg],
                 :slider_home=> ["355x212", :jpg],
                 :product_slider => ["651x340", :jpg],
                 :template_image => ["490x490", :jpg],
                 :homepage_image => ["190x140", :jpg],
                 :tell_your_story => ["160x300", :jpg]},

    #:path => "/prints/:id/:style.:extension",
    :default_url => "/images/missing/prints/:style.png"
    
end
