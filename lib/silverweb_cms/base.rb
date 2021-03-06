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
    
    def self.load_menu_types
      @MENU_TYPES = [["none",3],["page",1] , ["html",2], ["link",4], ["action",5]]
    end
    
    @MENU_TYPES = nil
    def self.MENU_TYPES
      @MENU_TYPES 
    end
    
    def self.add_menu_class(menu_class)
      @MENU_TYPES << menu_class
    end
    
    
    def self.load_menu_actions
      @ACTION_TYPES = [["none",0],["Product Category",1],["Product Category with Page",3], ["Gift Cards",6] ]
    end
        
    @ACTION_TYPES = nil
    def self.ACTION_TYPES
      @ACTION_TYPES
    end
    
    def self.add_menu_actions(menu_action)
      @ACTION_TYPES << menu_action
    end
  
    # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    #     R O U T E S  T O  A D D  F O R  D I R E C T  U R L  L I N K
    # * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    # 
    # 
    # This will hold a hash of routes and actions for direct links via names.
    
    @DIRECT_ROUTE_LIST = nil

    # Accessor used to access plugin configuration settings (returns a Hash that
    # directly corresponds to the contents of <tt>config/vtools_ui.yml</tt>)
    def self.DIRECT_ROUTE_LIST
      @DIRECT_ROUTE_LIST
    end
    
    #match ':page_name(.:format)', :controller => 'site', :action => 'show_page',  via: [:get]

    
    def self.load_route_list
      @DIRECT_ROUTE_LIST = [{:match=>":page_name(.:format)", :controller=>'site', :action=>'show_page', :via=>:get}]
    end
    
    def self.add_route_item(route_item)
      @DIRECT_ROUTE_LIST.insert(0,route_item)
    end
  end
end

SilverwebCms::Config.load_nav_list
SilverwebCms::Config.load_menu_types
SilverwebCms::Config.load_menu_actions
SilverwebCms::Config.load_route_list

