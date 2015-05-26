module SilverwebCms
  class Config

    # This will hold a hash of the settings defined in 'config/vtools_ui.yml'
    @GRID_NAV_LIST = nil

    # Accessor used to access plugin configuration settings (returns a Hash that
    # directly corresponds to the contents of <tt>config/vtools_ui.yml</tt>)
    def self.GRID_NAV
      @GRID_NAV_LIST
    end
    
    def self.load_nav_list
      @GRID_NAV_LIST = [{:name=>"Home", :controller=>'admin', :action=>'index'}, 
        {:name=>"Settings",:controller=>'admin', :action=>'site_settings'}, 
        {:name=>"Users",:controller=>'admin', :action=>'user_administration'}, 
        {:name=>"Menu", :controller=>'menus', :action=>'index'}, 
        {:name=>"Pages",:controller=>'pages', :action=>'index'}, 
        {:name=>"Page Templates",:controller=>'page_templates', :action=>'index'}, 
        {:name=>"Rights", :controller=>'rights', :action=>'index'}, 
        {:name=>"Roles", :controller=>'roles', :action=>'index'}]
    end
    
    def self.add_nav_item(nav_item)
      @GRID_NAV_LIST << nav_item
    end
  end
end
 
SilverwebCms::Config.load_nav_list

