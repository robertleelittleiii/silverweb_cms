module  MenusHelper
  
  def create_menu_list (menu_name, with_id=true)
   
    returnList=[]

    @menu = Menu.find_by_name(menu_name)

    if @menu.blank?  then
      returnList = ["Can't Find '"+ menu_name + "'"]
    else
    
      @menus = Menu.find_menu(@menu.id)
      if with_id then
        returnList = @menus.collect{|x| [x.name,x.id]}
      else
        returnList = @menus.collect{|x| x.name}
      end
      return returnList
    end
  end
  
  def create_menu_lowest_child_list(menu_name, menu_id=nil,with_id=true)
    if menu_id.blank? then
      if menu_name.blank? then
        return []
      else
        @start_menu = Menu.find_by_name(menu_name)
        if @start_menu.blank? then
          return "no menu found"
        end
      end
    else
      @start_menu = Menu.find(menu_id)
    end
      
    @menus = Menu.find_menu(@start_menu.id)
      
    return_list = []
    @menus.each do |menu|
      if menu.menus.size == 0 then
        if with_id then
          return_list = return_list + [[menu.name, menu.id]]
        else
          return_list = return_list + [menu.name]
        end
      else
        return_list= return_list + create_menu_lowest_child_list("",menu.id,with_id)
      end
    end
    return return_list
  end
    
  
  def find_top_menu(menu)
    if menu.menu.parent_id == 0 then
      return menu
    else
      return find_top_menu(menu.menu)
    end
  end

  def   buildmenuitem(menuItem, html_options, span_options, class_options=nil, options=nil)
    #    html_options = Menu.create_hash_from_string(menuItem.html_options)
    # html_options = {}
    return_link = ""
    
    puts("options-> #{options}")
    
    class_options==nil ? class_options={} : ""
    
    puts("menuItem.name:#{menuItem.name}")
    
    if menuItem.menu_active then
      menuText="<span "+ span_options +">"+menuItem.name + "</span>"

      if not options.blank? then
        if not options[:menu_name_sub_container].blank? then
          menu_sub_container_start = "<#{options[:menu_name_sub_container]}>"
          menu_sub_container_end= "</#{options[:menu_name_sub_container]}>"
        else
          menu_sub_container_start =  menu_sub_container_end= ""
        end
      
        if not options[:menu_name_container].blank? then
          menuText="<#{options[:menu_name_container]}" + span_options +">"+ menu_sub_container_start + menuItem.name + menu_sub_container_end + "</{options[:menu_name_container]}>"
        else
          menuText="<span "+ span_options +">"+ menu_sub_container_start + menuItem.name + menu_sub_container_end + "</span>"

        end
      end
     
      if(menuItem.has_image and not menuItem.pictures.empty?) then
        image_to_link_to = menuItem.pictures[0].image_url.to_s rescue "interface/missing_image_very_small.png"
        item_link_to = image_tag(image_to_link_to, :border=>"0", :alt=>menuItem.name.html_safe, :title=>menuItem.name.html_safe)
      else
        item_link_to = menuText.html_safe
      end
        
      case menuItem.m_type
      when "1"
        # menuText="<span "+ span_options +">"+menuItem.name + "</span>"
        if (menuItem.page_id.blank?)

        else      
          # class_options.merge!({:action => "show_page", :controller =>"site", :id=>menuItem.page_id})
          class_options = {}
          begin 
            class_options = "/" +  menuItem.page.title
            # class_options.merge!({:controller=>menuItem.page.title })
          rescue 
            class_options.merge!({:action => "show_page", :controller =>"site", :id=>menuItem.page_id})
          end
        end
       
        puts("------------ ------------------- -------------------")
        puts("item_link_to: #{item_link_to}")
        puts("class_options: #{class_options}")
        puts("html_options: #{html_options}")
        puts("------------ ------------------- -------------------")

        return_link =  link_to(item_link_to, class_options, html_options)
        
      when "2"
        return_link = menuItem.rawhtml
      when "3"
        # menuText="<span "+ span_options +">"+menuItem.name + "</span>"

        if(menuItem.has_image) then
          image_to_link_to = menuItem.pictures[0].image_url.to_s rescue "interface/missing_image_very_small.png"
          menuText = image_tag(image_to_link_to, :border=>"0", :alt=>menuItem.name.html_safe)
        else
          #  menuText="<span "+ span_options +">"+menuItem.name + "</span>"
        end
        return_link = link_to(menuText.html_safe, {},{:class=>'menu-title'})
      when "4"
        #  menuText="<span "+ span_options +">"+menuItem.name + "</span>"
        class_options = menuItem.rawhtml
     
        return_link =  link_to(item_link_to, class_options, html_options)

        #    return_link =  link_to(item_link_to, class_options, html_options.merge!(:target=>"_blank"))
      
      when "6"
        #  menuText="<span "+ span_options +">"+menuItem.name + "</span>"
        
        if menuItem.menu.parent_id == 0 then
          top_menu = menuItem
        else
          top_menu = menuItem.menu
        end
        
        
        class_options.merge!({:controller=>:site, :action=>:show_portfolios,:department_id=>top_menu.name, :category_id=>menuItem.name,})

        return_link =  link_to(item_link_to, class_options, html_options)

        #    return_link =  link_to(item_link_to, class_options, html_options.merge!(:target=>"_blank"))
      
      when "5"
      
        #  menuText="<span "+ span_options +">"+menuItem.name + "</span>"
        #top_menu = Menu.find(session[:parent_menu_id]) rescue {}
        if menuItem.menu.parent_id == 0 then
          top_menu = menuItem
        else
          top_menu = menuItem.menu
        end
      
        case menuItem.rawhtml
        when "1"
          
          class_options.merge!({:controller=>:site, :action=>:show_products, :department_id=>top_menu.name, :category_id=>menuItem.name})
          return_link =  link_to(item_link_to, class_options, html_options)
        
        when "2"
          
          class_options.merge!({:controller=>:site, :action=>:show_products, :department_id=>top_menu.name, :category_id=>menuItem.name, :category_children=>true})
          return_link =  link_to(item_link_to,class_options , html_options)
        
        when "3"
          if not menuItem.template.blank? then
            class_options.merge!({:controller=>:site, :action=>:show_products_with_page, :department_id=>(top_menu.name rescue ""), :category_id=>menuItem.name, :get_first_sub=>true, :category_children=>true, :page_id=>menuItem.page_id, :custom_layout=>menuItem.template})
          else
            class_options.merge!({:controller=>:site, :action=>:show_products_with_page, :department_id=>(top_menu.name rescue ""), :category_id=>menuItem.name, :get_first_sub=>true, :category_children=>true, :page_id=>menuItem.page_id})
          end
          return_link =  link_to(item_link_to, class_options, html_options)
        when "4"
          
          class_options.merge!({:controller=>:site, :action=>:show_products, :department_id=>top_menu.name, :category_id=>menuItem.name, :category_children=>true, :get_first_sub=>true})
          return_link =  link_to(item_link_to,class_options , html_options)
          
        when "5"
          
          class_options.merge!({:controller=>:site, :action=>:show_products_services, :department_id=>top_menu.name, :category_id=>menuItem.name, :category_children=>true, :get_first_sub=>true})
          return_link =  link_to(item_link_to,class_options , html_options)
       
        when "6"
          
        
          class_options.merge!({:controller=>:site, :action=>:show_products_services_simple, :department_id=>top_menu.name, :category_id=>menuItem.name, :category_children=>true, :get_first_sub=>true})
          return_link =  link_to(item_link_to,class_options , html_options)
        when "9"
          
          class_options.merge!({:controller=>:site, :action=>:show_artifact_group, :department_id=>top_menu.name, :category_id=>"", :category_children=>false, :get_first_sub=>true})
          return_link =  link_to(item_link_to,class_options , html_options)
       
        end 
      
      
      
        #  internal call to controller and action
        #                    class_options = { :action => menuItem.action, :controller =>menuItem.controller}.merge(Menu.create_hash_from_string(menuItem.class_options))
        #                    item_link_to = menuItem.name.upcase
        #                    return_link =  link_to(item_link_to, class_options, html_options)
        #                when 3
        #                    class_options = menuItem.url
        #                    item_link_to = menuItem.name
        #                    return_link =  link_to(item_link_to, class_options, html_options)
        #                 when 4
        #                    class_options = menuItem.url
        #                    item_link_to = image_tag(menuItem.picture)
        #                    return_link =  link_to(item_link_to, class_options, html_options)
        #                when 5
        #                   return_link = menuItem.raw_html
      else
        return_link =  send(menuItem.m_type, menuItem, html_options, span_options, class_options, options)  
      end     
    
      #puts(return_link)       

    
      return return_link.html_safe rescue "<none>"
    else
      return ""
    end
  end
  
  def buildverticlesubmenu(params=nil)
    puts("-------------------> #{params.inspect}")
    puts("******************> #{params[:menu_name]}")
    @menu_id = Menu.where(:name=>params[:menu_name]).first.id rescue session[:parent_menu_id] 
    
    puts("in build sub menu with:", session[:parent_menu_id] , @menu_id)
    
    if @menu_id==0 then
      puts("returning") 
      return("")
    else
    
      @menus = Menu.find(@menu_id) rescue (return(""))

      @prehtml = params[:prehtml] || ""
      @posthtml = params[:posthtml] || ""
   
      @article_name = params[:article_name] || ""
    
      html_options = {}
    
      html_options.merge!({:class=>params[:class]}) 

      returnMenu=""
    
      puts(@menus.inspect)
      for @menu in @menus.menus
        puts("@menu.name: #{@menu.name}, @article_name: #{@article_name} ")
        if @menu.name.downcase == @article_name.downcase
          returnMenu = returnMenu + params[:selected_class] + "<div class='menu-selected'>" + @menu.name + "</div>" + @posthtml
        else
          menuText =  self.buildmenuitem(@menu,html_options,"")
          if not menuText.blank? then
            returnMenu=  returnMenu + @prehtml + menuText + @posthtml
          end

        end
      
        if @menu.menus.count > 0 then
          if @menu.menu_active then
            returnMenu = returnMenu + buildsubmenus(@menu.menus, 0, params)
          end
        end
      
      end
      
      return returnMenu.html_safe
    end

  end
   
 
  def buildverticalmenu(params=nil)
    @menu_id= params[:menu_id]
    @prehtml = params[:prehtml]
    @posthtml = params[:posthtml]
    @current_page = params[:current_menu]
    
    @menu = Menu.find_by_name(@menu_id)
    html_options = {}
    
    html_options.merge!({:class=>params[:class]}) 
    
    returnMenu=""


    if @menu.blank? then
      returnMenu = "Can't Find '"+ @menu_id + "'" rescue "Can't find menu"
    else
      @menus = Menu.find_menu(@menu.id)

      for @menu in @menus
        # html_options = (@menu.name==@current_page ? html_options.merge!({:class=>"menu-selected"}) : html_options )
        if @menu.name==@current_page
          returnMenu = returnMenu + @prehtml + "<div class='menu-selected'>" + @menu.name + "</div>" + @posthtml 
        else
          menuText =  self.buildmenuitem(@menu,html_options,"")
          if not menuText.blank? then
            returnMenu=  returnMenu + @prehtml + menuText + @posthtml
          end
        
          if @menu.menus.count > 0 then
            if @menu.menu_active then
              returnMenu = returnMenu + buildsubmenus(@menu.menus, 0,params)
            end
          end
        
        end
      end
    end
    return returnMenu.html_safe
  end

  def buildhorizontalmenu(params=nil)
    puts("build menu params: #{params.inspect}")
    html_options = {}
    
    html_options.merge!({:class=>params[:class]}) 
    
    input_params = {}
    
    input_params.merge!({:top_menu=>true})
    
    @prehtml = params[:prehtml] || ""
    @posthtml = params[:posthtml] || ""
    @menu_id= params[:menu_id]
    @selected_class = params[:selected_class] || ""
    
    @page_name = params[:current_page] || @page_name
    # @page_name = (params[:current_page] || "") if @page_name.blank?

    if not @page_name.blank? then
      @current_sub_menu = Menu.find_by_name(@page_name) || Menu.all[0]
      @parent_name = @current_sub_menu.blank? ? "" : @current_sub_menu.menu.name rescue ""
      @parent_name = Menu.find(session[:parent_menu_id]).name rescue  ""  if @parent_name.blank? # menu_id
    end
    
    returnMenu=""

    @top_menu = Menu.find_by_name(@menu_id)
    
    if @top_menu.blank?  then
      returnMenu = "Can't Find '"+ @menu_id + "'"
    else
    
      @menus = Menu.find_menu(@top_menu.id)
      
      breaker_val = params[:breaker] || " | "
      breaker = ""

      menu_selected = false

      for @menu in @menus 
        if @menus.first == @menu then
          @prehtml=params[:prehtml_first] || params[:prehtml] || ""
        else 
          if @menus.last == @menu then
            @prehtml=params[:prehtml_last] || params[:prehtml] || ""
          end
        end
                
        
        
        
        menuText =  self.buildmenuitem(@menu,html_options,"", input_params)
        puts("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ")
        puts("menuText: #{menuText} menu: #{@menu.name} vs page name: #{params[:current_page]}")
        puts("parent_name: #{@parent_name}")
        puts("page_name: #{@page_name}")
        
        if not menuText.blank?  then
          if @menu.name == params[:current_page] and not menu_selected
            menu_selected=true  
            returnMenu=  returnMenu + breaker + @selected_class + menuText + @posthtml
            puts("Logic: @menu.name == params[:current_page] and not menu_selected")
          else 
            if @menu.name == @parent_name and not menu_selected then
              returnMenu=  returnMenu + breaker + @selected_class + menuText + @posthtml
              menu_selected = true
              puts("Logic: @menu.name == @parent_name and not menu_selected")
            else
              returnMenu=  returnMenu + breaker + @prehtml+ menuText + @posthtml
            end
          end
        end
        puts(returnMenu)
        puts("menu_selected: #{menu_selected}, @menu.name: #{@menu.name}, params[:current_page]: #{params[:current_page]} ")
       
        breaker = breaker_val
      end
    end
    # puts("Put S=>  #{h(params.to_json)}")
    
        
    return ("<div data-menu-params=' "+ h(params.to_json) + "' data-menu-id='#{@top_menu.id rescue 0}' cms-menu-helper='buildhorizontalmenu'>#{returnMenu}</div>").html_safe
  end

  def buildhorizontalmenuprodrop(params=nil)
    @menu_id= params[:menu_id]
    returnMenu=""
    html_li_class = params[:html_li_class]
    
    @menu = Menu.find_by_name(@menu_id)

    if @menu.blank?  then
      returnMenu = "Can't Find '"+ @menu_id + "'"
    else
      @menus = Menu.find_menu(@menu.id)
      
      breaker = ''
      breaker_val = params[:breaker] || ""

      
      for @menu in @menus
        if @menus.last == @menu then
          html_link_class="top_link last_link"
        else
          html_link_class="top_link"
        end
        puts("current page:#{params[:current_page]}, Menu Name:#{@menu.name} ")
        if @menu.name == params[:current_page]
          html_link_class = html_link_class +" "+ params[:selected_class]
        end

        if @menu.menus.count>0 then
          subMenus=self.buildsubmenus(@menu.menus,0, params)
          menuText =  self.buildmenuitem(@menu, {:class=>html_link_class}, "class='down'")
          if not menuText.blank? then
            returnMenu=  returnMenu + breaker + "<li class='top #{html_li_class}'>"+ menuText +subMenus+ "</li>"
          end
        else
          menuText =  self.buildmenuitem(@menu, {:class=>html_link_class}, "")
          if not menuText.blank? then
            returnMenu=  returnMenu + breaker  + "<li class='top #{html_li_class}'>" + menuText + "</li>"
          end
        end

        breaker = breaker_val.html_safe
      end
    end

    #	<li class="top"><a href="#nogo1" class="top_link"><span>Home</span></a></li>

    return("<ul data-menu-params='#{h(params.to_json)}' data-menu-id='#{@menu.id rescue "n/a"}' cms-menu-helper='buildhorizontalmenuprodrop' id='navi'>" + returnMenu + "</ul>").html_safe
      
  end
    
  def buildsubmenus(inputMenus, level, params)
    
    @prehtml = params[:prehtml] || ""
    @posthtml = params[:posthtml] || ""
    @selected_class = params[:selected_class] ||""
    @article_name = params[:article_name] || ""
    
    html_options = {}
    html_options.merge!({:class=>params[:class]}) 
    
    returnMenu = ""
    returnSubMenu = ""
    level = level + 1
    for eachmenu in inputMenus
      if eachmenu.menu_active then

        if eachmenu.name== @article_name then
          menu_text = "<div class='menu-selected'><span>" + eachmenu.name + "</span></div>"
        else
          menu_text = self.buildmenuitem(eachmenu, html_options.merge!( (eachmenu.menus.size > 0 ? {:class=>"fly"} : {})),"")
        end
      
        if eachmenu.menus.size > 0 then
          if eachmenu.menu_active then
            returnSubMenu = self.buildsubmenus(eachmenu.menus, level ,params)
            returnSubMenu = "<li class='mid'>"+ menu_text + returnSubMenu+ "</li>"
          else
            reutrnSubMenu= ""
          end
        else
          returnSubMenu = "<li>" + menu_text + "</li>"
        end
        returnMenu = returnMenu + returnSubMenu
      end
    end

    if level == 1 then
      returnMenu = "<ul class='sub'>" + returnMenu + "</ul>"
    end
    if level == 2 then
      returnMenu =  "<ul>" + returnMenu +"</ul>"
    end
    if level > 2 then
      returnMenu =  "<ul>" + returnMenu +"</ul>"
    end
    return returnMenu   
  end
    
  def menu_delete(menu)
    user =  User.find_by_id(session[:user_id])

    puts(user.name, user.roles.find_by_name("Admin"), menu.parent_id) rescue ""
        
    returnval=""
    if user.blank? then
          
    else
      if (not user.roles.find_by_name("Admin").nil?)
        # returnval = link_to(image_tag("interface/Button-Delete.png", :border=>"0") , menu, :class=>"delete_menu",  data: { confirm: 'Are you sure?' }, :method => :delete , :remote=>true)
        returnval = image_tag("interface/Button-Delete.png", :border=>"0", :class=>"delete_menu")
      else
        if menu.parent_id==0

        else
          #  returnval = link_to(image_tag("interface/Button-Delete.png", :border=>"0") , menu, :class=>"delete_menu",  data: { confirm: 'Are you sure?' } , :method => :delete , :remote=>true)
          returnval = image_tag("interface/Button-Delete.png", :border=>"0", :class=>"delete_menu")
        end
          
      end
      return returnval
    end
  end
  
  def buildhorizontalmenusuperfish(params=nil)
    @menu_id= params[:menu_id]
    returnMenu=""
    item_tag = params[:item_tag] || "li"
    @menu = Menu.find_by_name(@menu_id)

    if @menu.blank?  then
      returnMenu = "Can't Find '"+ @menu_id + "'"
    else
      menus = Menu.find_menu(@menu.id)

      breaker = ''
      breaker_val = params[:breaker] || ""
      class_val = "class='sf-menu " + params[:class] + "'" || "class='sf-menu' "
      
      menus.each_with_index  do |menu, index | 
        #for menu in menus
        if menu.menu_active then
          if params[:colorize_index_count] then
            colorized_class =    "primary-color-" + (index % params[:colorize_index_count].to_i ).to_s
          else
            colorized_class = ""
          end
        
          html_link_class = ""
          if menus.last == menu then
            html_li_class="last"
          else   
            if menus.first == menu then
              html_li_class="first"
            else
              html_li_class="middle"
            end
          end
          puts("current page:#{params[:current_page]}, Menu Name:#{menu.name} ")
          if menu.name == params[:current_page]
            html_link_class = params[:selected_class]
          end

          if menu.menus.count>0 then
            subMenus=self.buildsubmenussuperfish(menu.menus,0,params)
            if subMenus.include?(params[:selected_class]) then
              html_link_class = params[:selected_class]
            end
            returnMenu=  returnMenu + breaker + "<#{item_tag} class='top #{html_li_class} #{colorized_class} #{html_link_class}'>"+ self.buildmenuitem(menu, {:class=>html_link_class}, "", nil ,params) +subMenus+ "</#{item_tag}>"
          else
            returnMenu=  returnMenu + breaker  + "<#{item_tag} class='top #{html_li_class} #{colorized_class} #{html_link_class}'>" + self.buildmenuitem(menu, {:class=>html_link_class}, "", nil ,params) + "</#{item_tag}>"
          end

          breaker = breaker_val.html_safe
        end
      end
    end

    #	<li class="top"><a href="#nogo1" class="top_link"><span>Home</span></a></li>

    return("<ul data-menu-params='#{h(params.to_json)}' data-menu-id='#{@menu.id rescue "n/a"}' cms-menu-helper='buildhorizontalmenusuperfish' #{class_val}>" + returnMenu + "</ul>").html_safe
      
  end
  
  def buildsubmenussuperfish(inputMenus, level, params=nil)
    returnMenu = ""
    returnSubMenu = ""
    html_link_class = ""
    colorized_class = ""

    level = level + 1
    item_tag = params[:item_tag] || "li"

    
    inputMenus.each_with_index  do |eachmenu, index | 
      if eachmenu.menu_active then
       if eachmenu.name == params[:current_page]
          html_link_class = params[:selected_class]
        else 
          html_link_class = ""
        end
      
        #puts("-------------->>>> params[:colorize_sub_index_count] #{params[:colorize_sub_index_count]}")
      
        if params[:colorize_sub_index_count] then
          colorized_class = "color-" + (index % params[:colorize_sub_index_count].to_i).to_s
        else
          colorized_class = ""
        end
        
        if eachmenu.menus.size > 0 then 
      
          returnSubMenu = self.buildsubmenussuperfish(eachmenu.menus, level, params)
          returnSubMenu = "<#{item_tag}>"+ self.buildmenuitem(eachmenu, {:class=>(html_link_class + " " + colorized_class) }, "", nil ,params)+ returnSubMenu+ "</#{item_tag}>"
        else
          returnSubMenu = "<#{item_tag}>" + self.buildmenuitem(eachmenu, {:class=>(html_link_class + " " + colorized_class) },  "", nil ,params) + "</#{item_tag}>"
        end
        returnMenu = returnMenu + returnSubMenu
      end
    end
    if level == 1 then
      returnMenu = "<ul>" + returnMenu + "</ul>"
    end
    if level == 2 then
      returnMenu =  "<ul>" + returnMenu +"</ul>"
    end
    if level > 2 then
      returnMenu =  "<ul>" + returnMenu +"</ul>"
    end
    
    return returnMenu   
  end
  
    
  def menu_edit_div(menu, div_id="")
    returnval=""
    if session[:user_id] then
      user=User.find(session[:user_id])
      if user.roles.detect{|role|((role.name=="Admin") | (role.name=="Site Owner"))} then
        returnval = "<div id=\""+ (div_id=="" ? "edit-menu" : div_id) + "\" class='edit-menu'>"
        returnval << "<div id='menu-id' class='hidden-item'>#{menu.id}</div>"
        returnval << image_tag("interface/edit.png",:border=>"0", :class=>"imagebutton", :title => "Edit this Menu") # link_to(image_tag("interface/edit.png",:border=>"0", :class=>"imagebutton", :title => "Edit this Page"),:controller => 'portfolios', :id =>portfolio.id ,  :action => 'edit')
        returnval << "</div>"
      end
    end
    return returnval.html_safe
  end
end