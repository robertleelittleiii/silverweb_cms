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
    
    def self.shortcut_grid_nav(short_cuts)
       new_array = []
      current_grid_nav = @GRID_NAV_LIST.dup

      current_grid_nav.each_with_index do |nav_item,index|
        if nav_item[:id].blank?
          nav_item[:id] = nav_item[:name].sub(" ","-")
          current_grid_nav[index] = nav_item
        end
      end
    
      short_cuts.each do |order_item|
        reorderd_item = current_grid_nav.select{|item| item[:id] == order_item} 
        
        new_array << reorderd_item[0] if !reorderd_item.blank?
      end
            
      return new_array
      
    end
    
    def self.reorder_grid_nav(new_order)
      new_array = []
      current_grid_nav = @GRID_NAV_LIST.dup

      current_grid_nav.each_with_index do |nav_item,index|
        if nav_item[:id].blank?
          nav_item[:id] = nav_item[:name].sub(" ","-")
          current_grid_nav[index] = nav_item
        end
      end
    
      new_order.each do |order_item|
        reorderd_item = current_grid_nav.select{|item| item[:id] == order_item} 
        current_grid_nav = current_grid_nav.reject{|item| item[:id] == order_item} 
        
        new_array << reorderd_item[0] if !reorderd_item.blank?
      end
      
      new_array = new_array + current_grid_nav
      
      return new_array
    end
    
    def self.load_menu_types
      @MENU_TYPES = [["none",3],["page",1] , ["html",2], ["link",4], ["action",5]]
    end
    
    # MENU FIELDS TO ALLOW LATER GEMS TO ADD TO MENU OBJECT.
    
    @MENU_FIELDS = [""]
    
    def self.load_menu_fields
      @MENU_FIELDS = [""]
    end
    
    
    def self.add_menu_fields(menu_fields)
      @MENU_FIELDS << menu_fields
    end
    
    def self.MENU_FIELDS
      @MENU_FIELDS
    end
    
    # MENU TYPES
    
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
  
    
    # USER DATA FIELD PARTIAILS TO ALLOW LATER GEMS TO ADD TO USER INFO WIDGET.
    
    @USER_PANES = []
    
   
    def self.USER_PANES
      @USER_PANES 
    end
    
    def self.add_user_pref_pane(pref_pane)
      @USER_PANES << pref_pane
    end
    
    
    # USER ALLOW EDIT ATTR TO ALLOW LATER GEMS TO ADD TO USER FILEDS FOR EDIT.

    @USER_PERMITED_FIELDS = []
    
    def self.USER_PERMITTED_FIELDS
      @USER_PERMITED_FIELDS 
    end
    
    def self.add_user_permitted_fields(fields_to_add)
      @USER_PERMITED_FIELDS << fields_to_add
    end
    
    
    
    # USER ATTRIBUTE ALLOW EDIT ATTR TO ALLOW LATER GEMS TO ADD TO USER FILEDS FOR EDIT.

    @USER_ATTRIBUTE_PERMITTED_FIELDS = []
    
    def self.USER_ATTRIBUTE_PERMITTED_FIELDS
      @USER_ATTRIBUTE_PERMITTED_FIELDS 
    end
    
    def self.add_user_attribute_permitted_fields(fields_to_add)
      @USER_ATTRIBUTE_PERMITTED_FIELDS << fields_to_add
    end
    
    
    # SITE DATA FIELD PARTIAILS TO ALLOW LATER GEMS TO ADD TO USER INFO WIDGET.
    
    @SITE_PANES = []
    
   
    def self.SITE_PANES
      @SITE_PANES 
    end
    
    def self.add_site_pref_pane(pref_pane)
      @SITE_PANES << pref_pane
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
SilverwebCms::Config.load_menu_fields
SilverwebCms::Config.load_route_list

