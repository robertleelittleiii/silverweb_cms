class Page < ActiveRecord::Base
  #  belongs_to :menu
  versioned only: [:title, :body]

  has_one :menu
  has_many :sliders , -> { order 'slider_order'}
  
  acts_as_taggable_on :security_group

  
  def name()
    return_name =   self.menu.nil? ? self.title : self.menu.name
    return return_name
  end
  
  def page_url
    return_url = Menu.where(page_id: id, m_type: ["1","5"]).first.menu_url rescue "/#{title rescue "n/a"}"
 
    return_url = "/#{title rescue "n/a"}" if return_url==""
    
    return return_url
    
    
  end
  
  def public_title
    slug.blank? ?  title.downcase.gsub(" ","-") : slug 
  end
  
end
