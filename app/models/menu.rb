class Menu < ActiveRecord::Base

  has_many :menus, -> {order "m_order ASC"}, foreign_key: :parent_id, dependent: :destroy
  has_many :pictures, ->{order(:position)}, dependent: :destroy, as: :resource

  belongs_to :menu,  foreign_key: :parent_id, optional: true
  
  belongs_to :page, optional: true
  
  acts_as_taggable_on :menu_names
  
  before_save :tag_menu
  
  # validates :name, :uniqueness => true
  
  # has_one :page

  validate :top_level_menus_must_be_unique

  def top_level_menus_must_be_unique
    if name != name_was then
      parent_id = self.menu.parent_id rescue -1
    
      if parent_id == 0 and not Menu.where(name: name).blank? then
        errors.add(:name, "Department must be unique!!")
      end
    end
  end
 
  
  
  
  def self.find_root_menus()
    where(parent_id: 0)
    # find(:all, conditions: [ "parent_id = 0"])
  end

  def self.find_menus_by_parent_id(parent_id)
    today = Time.now
    where(:parent_id=>parent_id)
  end

  def self.find_menu(parent_id)
    
    where(parent_id: parent_id).order( "m_order ASC")
    
    # find(:all, conditions: ["parent_id = (?)", parent_id]   ,order: "m_order ASC")

  end
  def top_level_menu?
    menu.parent_id==0 rescue false
  end
    
  def find_top_level_parent
    
    if parent_id==0 then
   #   puts("found parent:#{id} ")
      return id
    else
    #  puts("check next level ^")
      return menu.find_top_level_parent
    end rescue return 0
  end
  
  
  def tag_menu
    # return if self.parent_id == 0 or self.menu.parent_id == 0 rescue return
    
    if top_level_menu? then
      # puts("Top menu::: Department")
            
      if menu_names.count > 0 then
        current_tag = ActsAsTaggableOn::Tag.where(name: name)
      
        if current_tag.count > 0 then
          #Tag name already exists, this will merge items with this menu
          menu_name_tags = menu_names
        
          tagged_items = menu_name_tags[0].taggings
        
          tagged_items.each do |tagged_item|
            tagged_item.tag_id = current_tag[0].id
            tagged_item.save
          end
        
          self.menu_name_list = []
          self.menu_name_list.add(name)

        else
          #Tag doesn't exist in the system yet. We must create a new tag and assign it to the items that are tagged.    
        
          # create the new tag
          new_tag_id = ActsAsTaggableOn::Tag.maximum(:id)+1
          new_tag = ActsAsTaggableOn::Tag.new(name: name)
          new_tag.id = new_tag_id
          new_tag.save

        
          menu_name_tags = menu_names
        
          tagged_items = menu_name_tags[0].taggings
        
          tagged_items.each do |tagged_item|
            tagged_item.tag_id = new_tag_id
            tagged_item.save
          end
        
          self.menu_name_list.add(name)
        end

        
      else
        self.menu_name_list.add(name)
      end
    else
      # puts("sub menu::: category: #{name}")
      if menu_names.count > 0 then
        
        current_tags = ActsAsTaggableOn::Tag.where(name: name)
        
        if current_tags.count == 0 then
          new_tag_id = ActsAsTaggableOn::Tag.maximum(:id)+1
          current_tag = ActsAsTaggableOn::Tag.new(name: name)
          current_tag.id = new_tag_id
          current_tag.save
        else
          current_tag = current_tags.first
        end
        
        top_menu_id = self.find_top_level_parent
        top_menu = Menu.find(top_menu_id) rescue 0
      
        department_id = top_menu.menu_names[0].id rescue 0
      
        category_id = self.menu_names[0].id
        
        
        # puts("Department: #{department_id}, Category: #{category_id}")
        query = "SELECT distinct t2.* FROM `taggings` t1, `taggings` t2 WHERE  t1.tag_id=#{department_id} and t2.tag_id=#{category_id} and t1.taggable_id=t2.taggable_id"
        # puts("query: #{query}")
        recatagorize_results = ActsAsTaggableOn::Tagging.find_by_sql(query)
        # puts("recatorize_results: #{recatagorize_results.inspect}")
        recatagorize_results.each do |tagged_item|
          # puts("taggings_id: #{tagged_item.id}, tagged_item.tag_id #{tagged_item.tag_id},  current_tag.id #{ current_tag.id}")

          tagged_item.tag_id = current_tag.id
          tagged_item.save
        end
        
        self.menu_name_list = []
        self.menu_name_list.add(name)

        
      else
        self.menu_name_list.add(name)
      end
      
      
      
           
    end
    
    # puts("---before save---")
       
  end
  
  #  menu_url
  #  this will return the URL for the menu item as defined.  It is being used so the page preview knows
  #  how it is defined by the system and therefor will show you in that view.
  #
  def menu_url  
    
    if not menu.nil? and menu.parent_id == 0 then
      top_menu = self
    else
      top_menu = menu
    end
        
    case m_type
    when "1"
      "/#{page.title rescue "n/a"}"
    when "2"
      ""
    when "3"
      ""
    when "4"
      menuText
    when "5"
      case rawhtml
      when "1"
        "/site/show_products?department_id=#{top_menu.name}&category_id=#{name}"
      when "2"
        "/site/show_products?department_id=#{top_menu.name}&category_id=#{name}&category_children=true"

      when "3"
        "/site/show_products_with_page?department_id=#{top_menu.name}&category_id=#{name}&category_children=true&page_id=#{page_id}"
      when "4"
        "/site/show_products?department_id=#{top_menu.name}&category_id=#{name}&page_id=#{page_id}&category_children=true&get_first_sub=true"

      end
      
      
    end
  end
  
end
