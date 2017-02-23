module UiHelper

  #  This will hide or show a div based on the given condition.
  def hidden_div_if(condition, attributes = {})
    if condition
      attributes["style"] = "display: none"
    end
    attrs = tag_options(attributes.stringify_keys)
    "<div #{attrs}>".html_safe
  end
  
      
  def add_google_analytics
    tracking_id = Settings.google_analytics
    begin 
      user_id = User.find(session[:user_id]).name || 'visitor' 
    rescue
      user_id = 'visitor'
    end
    
    if not tracking_id.blank? then
      data ="<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', '#{tracking_id}', 'auto');
  ga('send', 'pageview');
  ga('set', '&uid', '#{user_id}'); // Set the user ID using signed-in user_id.
</script>".html_safe
      
      return data
    end
  end

  def old_add_google_analytics
    tracking_id = Settings.google_analytics
    if not tracking_id.blank? then
      data = "<script type=\"text/javascript\" async>

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', '#{tracking_id}']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>".html_safe
      return data
    end
    
  end
  
   def add_pintrest_verification_code 
    pintrest_id = Settings.pintrest_id
    if not pintrest_id.blank? then
    "<meta name='p:domain_verify' content='#{pintrest_id}'//>".html_safe
    end
  end
  
  def asset_available? logical_path
    if Rails.configuration.assets.compile
      Rails.application.precompiled_assets.include? logical_path
    else
      Rails.application.assets_manifest.assets[logical_path].present?
    end
  end
  
  
  #  This will autoload css files based on the controller and/or action
  def controller_stylesheet_link_tag
    stylesheet = "#{params[:controller]}.css"
  #  stylesheet_path = Rails.application.assets.find_asset(stylesheet)
 #   stylesheet_path = Rails.application.assets_manifest.files.values.map{|v| v['logical_path']}.include?('#{stylesheet}')
    stylesheet_path = asset_available? stylesheet
    
    puts('testingtestingtesting');
    puts("stylesheet: #{stylesheet}----> stylesheet_path: '#{stylesheet_path}'");
    
    stylesheetaction = "#{params[:controller]}/#{params[:action]=="index" ? "index_" : params[:action]}.css"
   #  stylesheetaction_path = Rails.application.assets.find_asset(stylesheetaction)
   #  stylesheetaction_path = Rails.application.assets_manifest.files.values.map{|v| v['logical_path']}.include?('#{stylesheetaction}')
    stylesheetaction_path = asset_available? stylesheetaction

    puts("stylesheetaction: #{stylesheetaction}---> stylesheetaction_path '#{stylesheetaction_path}'");

    stylesheet_return = ""
  
    if  stylesheet_path then
      stylesheet_return = stylesheet_link_tag stylesheet rescue ""
    end
    
    if stylesheetaction_path then # and (stylesheet_path != stylesheetaction_path) then
      stylesheet_return = stylesheet_return + " " + (stylesheet_link_tag stylesheetaction) rescue ""
    end
    
    if not @style_sheet_custom.nil? and not @style_sheet_custom.blank?  then
      custom_stylesheet = "#{params[:controller]}/#{@style_sheet_custom}"
  #    custom_stylesheet_path = Rails.application.assets.find_asset(custom_stylesheet)
  #     custom_stylesheet_path = Rails.application.assets_manifest.files.values.map{|v| v['logical_path']}.include?('#{custom_stylesheet}')
      custom_stylesheet_path = asset_available? custom_stylesheet
   stylesheet_return <<  (stylesheet_link_tag(custom_stylesheet,"data-turbolinks-track"=>"true")) if  custom_stylesheet_path rescue ""
    end
     
    return stylesheet_return.html_safe if not stylesheet_return.blank?
    
  end
  
  #  This will autoload javascript files based on the controller and/or action 

  def controller_javascript_include_tag
    
    javascript = "#{params[:controller]}.js"
#    javascript_path = Rails.application.assets.find_asset(javascript)
#    javascript_path = Rails.application.assets_manifest.files.values.map{|v| v['logical_path']}.include?('#{javascript}')
    javascript_path = asset_available? javascript
  puts('testingtestingtesting');
    puts("javascript: #{javascript}----> javascript_path: '#{javascript_path}'");
 
    javascriptaction = "#{params[:controller]}/#{params[:action]=="index" ? "index_" : params[:action]}.js"
 #   javascriptaction_path = Rails.application.assets.find_asset(javascriptaction)
 #   javascriptaction_path = Rails.application.assets_manifest.files.values.map{|v| v['logical_path']}.include?('#{javascriptaction}')
    javascriptaction_path = asset_available? javascriptaction
  puts('testingtestingtesting');
    puts("javascriptaction: #{javascriptaction}----> javascriptaction_path: '#{javascriptaction_path}'");
 
    javascript_return = ""
           
    # Rails.application.assets.find_asset(javascriptaction) != nil

    # if File.exists?(File.join(Rails.root, '/assets/javascripts', javascript))
    if  javascript_path then
      javascript_return = javascript_include_tag(javascript, :async => true) rescue ""
    end

    if javascriptaction_path  then # and (javascript_path != javascriptaction_path) then
      javascript_return = javascript_return + " " + (javascript_include_tag(javascriptaction, :async => true)) rescue ""
    end
    
  
    if not @java_script_custom.nil? and not @java_script_custom.blank?  then
      custom_javascriptaction = "#{params[:controller]}/#{@java_script_custom}"
 #     custom_javascriptaction_path = Rails.application.assets.find_asset(custom_javascriptaction)
 #     custom_javascriptaction_path = Rails.application.assets_manifest.files.values.map{|v| v['logical_path']}.include?('#{custom_javascriptaction}')
    custom_javascriptaction_path = asset_available? custom_javascriptaction

      javascript_return <<  (javascript_include_tag(custom_javascriptaction,:async => true)) if  custom_javascriptaction_path
    end
    
    return javascript_return.html_safe if not javascript_return.blank?

  end
  
  def best_in_place(object, field, opts = {})
    logger.info("best_in_place")
    logger.info(opts[:class])
    puts("object: #{object}, field: #{field}, opts: #{opts.inspect}")
    puts("object: #{object}, field: #{field}, opts: #{opts.inspect}")
  
    opts[:type] ||= :input
    opts[:collection] ||= []

    field = field.to_s
    puts("bestinplace->>> field is: #{field}")
    puts("bestinplace->>> Object is: #{object.inspect}")
    
    field_items = field.split(".")
    
    if field.include?("[") and field.include?("]") then
      array_index = field.scan(/\[(.*?)\]/).flatten.first.to_i
      field_name = field.split("[").first
      value = object.send(field_name)[array_index] rescue ""
    else
      value = (field_items.length > 1 ? object.send(field_items[0]).send(field_items[1]) : object.send(field) ) rescue object[field]
    end
    
    value = value.blank? ? "" : value
    
    puts("bestinplace->>> Value is: #{value}")

    collection = nil
    if opts[:type] == :select && !opts[:collection].blank?
      v = object.send(field)
      logger.info(v)
      logger.info(opts[:collection])
      value = Hash[opts[:collection]][!!(v =~ /^[0-9]+$/) ? v.to_i : v] || "Please Select..."
      collection = opts[:collection].to_json
    end
    
    #fix for rails settings gem
    object_class_name = object.class.to_s.gsub("::", "_").underscore
    object_class_name = (object_class_name == "settings_active_record_relation" ? "settings" : object_class_name)

    
    if opts[:type] == :checkbox
      if object_class_name == "settings" then
        fieldValue = Settings.send(field) == "true" ? true : false
      else
        fieldValue = !!object.send(field)
      end
      if opts[:collection].blank? || opts[:collection].size != 2
        opts[:collection] = ["No", "Yes"]
      end
      value = fieldValue ? opts[:collection][1] : opts[:collection][0]
      collection = opts[:collection].to_json
    end
    extraclass = "'"
    if !opts[:class].blank? 
      extraclass = opts[:class] + "'"
    end
           
    
    if object_class_name == "settings" then
      opts[:path] = request.original_url
    end rescue ""
    
    puts("object-class-name in bestinplace: #{object_class_name}")
    
    out = "<div class='best_in_place " + extraclass
    out << " id='best_in_place_#{object_class_name}_#{field}'"
    out << " data-url='#{opts[:path].blank? ? url_for(object).to_s : url_for(opts[:path]) rescue "/"}'"
    out << " data-object='#{object_class_name}'"
    out << " data-collection='#{collection}'" unless collection.blank?
    out << " data-attribute='#{field}'"
    out << " data-activator='#{opts[:activator]}'" unless opts[:activator].blank?
    out << " data-nil='#{opts[:nil].to_s}'" unless opts[:nil].blank?
    out << " data-type='#{opts[:type].to_s}'"
    out << " data-max-length='#{opts[:max_length].to_s}'" unless opts[:max_length].blank?
    out << " data-format='#{opts[:format_string].to_s}'" unless opts[:format_string].blank?
    out << " data-format-type'#{opts[:format_type].to_s}'" unless opts[:format_type].blank?

    # formating options if set
    #  :format_type 
    #      "date"
    #           Will look at the opt[:format_string] to format as datetime.
    #      "currency"
    #           Will simply use the rails number_to_currency on the value to format.
    #
    
    puts()
    if not opts[:format_type].blank?  then
      case opts[:format_type] 
      when "time"
        value =  Time.parse(value.to_s).strftime(opts[:format_string]) if not value.blank?
      when "date"
        value =  Date.parse(value.to_s).strftime(opts[:format_string]) if not value.blank?
      when "datetime"
        value =  DateTime.parse(value.to_s).strftime(opts[:format_string]) if not value.blank?
      when "currency"
        value =  number_to_currency(value) if not value.blank?
      else
        # do nothing
      end
    end
    
    if !opts[:sanitize].nil? && !opts[:sanitize]
      out << " data-sanitize='false'>"
      out << sanitize(value.to_s, :tags => %w(b i u s a strong em p h1 h2 h3 h4 h5 ul li ol hr pre span img), :attributes => %w(id class))
    else
      out << ">#{sanitize(value.to_s, :tags => nil, :attributes => nil)}"
    end
    
# TODO: give users the ability to so simple formating on fields.
# 
#    if opts[:simple_format] == "true" then
#     value = simple_format(value.to_s)
#    end
#    
    out << "</div>"
    
    if !opts[:validation_message].blank? then
      out << "<lable data-attribute='#{field}' class='best_in_place_validation'>"
      out << opts[:validation_message]
      out << "</lable>"
    end
    
    return out
  end
  
  def editablefieldcreate(field_name,field_pointer, empty_message="Click me to add content!", opts = {})
 
    # puts("field_name: #{field_name}, field_pointer: #{field_pointer}, opts: #{opts.inspect}")
    if field_pointer.blank? then
      flash[:notice] = field_name + " not found !!"
      return "ERROR"
    end
    if opts[:divclass].nil? then
      divClass='cms-contentitem'
    else
      divClass=opts[:divclass] + " cms-contentitem"
    end rescue divClass='cms-contentitem'

    if (field_pointer[field_name].class == String and field_pointer[field_name].length > 85) or opts[:force_textarea] then
      ("<div id='field_#{field_name.to_s}' class='#{divClass}'>" +
          best_in_place(field_pointer, field_name, opts.merge(:type => :textarea, :nil => empty_message)).html_safe +
          '</div>').html_safe
    else 
      ("<div id='field_#{field_name.to_s}' class='#{divClass}'>" +
          best_in_place(field_pointer, field_name, opts.merge(:type => :input, :nil => empty_message)).html_safe +
          '</div>').html_safe
    end
  end
  
  def editabledatefieldcreate(field_name,field_pointer, empty_message="Click me to add content!", opts = {})

    if field_pointer.blank? then
      flash[:notice] = field_name + " not found !!"
      return "ERROR"
    end
    if opts[:divclass].nil? then
      divClass='cms-contentitem'
    else
      divClass=opts[:divclass]
    end rescue divClass='cms-contentitem'
    
    ("<div id='field_#{field_name.to_s}' class='#{divClass}'>" +
        best_in_place(field_pointer, field_name,opts.merge( :type => :date, :nil => empty_message)).html_safe +
        '</div>').html_safe
     
  end
  
  def editabledatetimefieldcreate(field_name,field_pointer, empty_message="Click me to add content!", opts = {})

    if field_pointer.blank? then
      flash[:notice] = field_name + " not found !!"
      return "ERROR"
    end
    if opts[:divclass].nil? then
      divClass='cms-contentitem'
    else
      divClass=opts[:divclass]
    end rescue divClass='cms-contentitem'
    
    ("<div id='field_#{field_name.to_s}' class='#{divClass}'>" +
        best_in_place(field_pointer, field_name,opts.merge( :type => :datetime, :nil => empty_message)).html_safe +
        '</div>').html_safe
     
  end
  
  def editablecheckboxeditmulti (field_name, field_pointer ,field_title, opts={})

    db_field_name= field_name.split("-").first
    is_selected = field_pointer[db_field_name].split(",").include?(field_title) rescue false  
    divClass = (opts[:divclass].blank? ? "cms-contentitem ajax-check-multi" : opts[:divclass])
    
    
    ( "<div class='#{divClass}' >"  + check_box_tag("#{field_name}", field_title, is_selected, 
      data:{
        remote: true,
        method: "PUT",
        type: "JSON",
        url:
          url_for(
            id: field_pointer.id,
            selected: is_selected,
            action: :update,
            "#{field_pointer.class.name.downcase}" => {"#{field_name}"=> field_title}   ) 
      }, 
      :class => "ajax-check-multi",
      checkbox_value: field_title
    )+field_title + "</div>").html_safe
      
    # check_box_tag( "#{field_name}",field_title, is_selected , html_options.merge!({
    #       :onchange => "#{remote_function(:url  => {:action => "update_checkbox_multi", :id=>field_pointer.id, :field=>db_field_name ,:pointer_class=>field_pointer.class, :checkbox_value=>field_title},
    #       :with => "'current_status='+checked")}"}))+field_title

  end
  
  
#                 <b> Sample: editablecheckboxtag </b></br>
#                <p>
#                    <%= editablecheckboxtag("billing_type", @job,"testing", {:check_value => "testing"}) %>
#                </p>
#                <b> Sample: editablecheckboxeditmulti </b></br>
#                <p>
#                    <%= editablecheckboxeditmulti("document_list", @job,"testing") %>
#                </p>

  
  def editablecheckboxtag (field_name, field_pointer,field_title, opts = {})
  
    if field_pointer.blank? then
      flash[:notice] = field_name + " not found !!"
      return "ERROR"
    end
    if opts[:divclass].nil? then
      divClass='class="cms-contentitem"'
    else
      divClass=opts[:divclass]
    end rescue divClass='class="cms-contentitem"'
    
    check_action = opts[:check_action] || :update
    check_value = opts[:check_value] ||  true
    is_selected = opts[:check_box_checked] || (field_pointer[field_name] == check_value)
    
    (check_box_tag("#{field_name}", field_title, is_selected, 
      data:{
        #remote: true,
        method: "PUT",
        type: "JSON",
        url: url_for(field_pointer).to_s 
      },
      :class => "ui-ajax-checkbox",
      checkbox_value: field_title,
      "data-path"=>url_for(field_pointer).to_s ,
      "data-id"=>field_pointer.id,
      "data-class"=>field_pointer.class.name.underscore,
      "data-action"=>check_action,
      "data-check-type"=> (opts[:check_value].blank? ? "boolean" : "string")
    )+field_title).html_safe
  
    end
  

    def editablecheckboxedit (field_name, field_pointer,field_title, opts = {})
  
      if field_pointer.blank? then
        flash[:notice] = field_name + " not found !!"
        return "ERROR"
      end
      if opts[:divclass].nil? then
        divClass='class="cms-contentitem"'
      else
        divClass=opts[:divclass]
      end rescue divClass='class="cms-contentitem"'
    
      ('<div id="field_'+field_name.to_s + '"' + divClass + '> ' + (!field_title.blank? ?   '<div class="checkbox-title">' + field_title + ": </div>" : "") +
          best_in_place(field_pointer, field_name, opts.merge(:type => :checkbox)).html_safe +
          '</div>').html_safe
      
      #check_box_tag( "#{field_name}", field_pointer.id, field_pointer[field_name], {
      #    :onchange => "#{remote_function(:url  => {:action => "update_checkbox", :id=>field_pointer.id, :field=>field_name ,:pointer_class=>field_pointer.class},
      #    :with => "'current_status='+checked")}"})+field_title

    end
  
    def create_group_checkbox_live(field_name, field_pointer, value_list, html_options={})
    
      return_value = ""
    
      value_list.each do |item|
        return_value =  return_value + editablecheckboxeditmulti(field_name, field_pointer,item, html_options)  
      end
      return content_tag(:div,return_value, html_options,false)
    end
  
    #    def create_group_checkbox_live(field_name, field_pointer, value_list, html_options={})
    #    
    #      return_value = ""
    #    
    #      value_list.each do |item|
    #        return_value =  return_value + editablecheckboxeditmulti(field_name, field_pointer,item, html_options)  
    #      end
    #      return content_tag(:div,return_value, html_options,false)
    #    end
  
  
    #    def editablecheckboxeditmulti (field_name, field_pointer ,field_title, html_options={},opts={} )
    #
    #      db_field_name= field_name.split("-").first
    #      is_selected = field_pointer[db_field_name].split(",").include?(field_title) rescue false  
    #    
    #      if field_pointer.blank? then
    #        flash[:notice] = field_name + " not found !!"
    #        return "ERROR"
    #      end
    #      if opts[:divclass].nil? then
    #        divClass='class="cms-contentitem"'
    #      else
    #        divClass=opts[:divclass]
    #      end rescue divClass='class="cms-contentitem"'
    #    
    #      ('<div id="field_'+field_name.to_s + '"' + divClass + '> ' + (!field_title.blank? ?   '<div class="checkbox-title">' + field_title + ": </div>" : "") +
    #          best_in_place(field_pointer, field_name, opts.merge(:type => :checkbox)).html_safe +
    #          '</div>').html_safe
    #      
    #      #check_box_tag( "#{field_name}", field_title,is_selected , html_options.merge!({
    #      #      :onchange => "#{remote_function(:url  => {:action => "update_checkbox_multi", :id=>field_pointer.id, :field=>db_field_name ,:pointer_class=>field_pointer.class, :checkbox_value=>field_title},
    #      #      :with => "'current_status='+checked")}"}))+field_title
    #
    #    end
  
    def create_group_checks_live(field_name, field_pointer, value_list, tag_list_name, html_options={})
      return_value = ""
    
      value_list.each do |item|
        return_value =  return_value + "<div class='div-#{tag_list_name}'>"+ editablecheckboxtag2(item, field_pointer,item,tag_list_name,html_options) +"</div>" 
      end
      return return_value.html_safe
    end
  
    def editablecheckboxtag2  (field_name, field_pointer,field_title, tag_list_name,html_options={}, include_id=false )
      tag_name="#{tag_list_name.singularize}_list"
      tag_array1= field_pointer.send(tag_name)
      tag_id = field_title[1].to_s || ""
      tag_array= tag_array1.collect { |item| item.downcase.strip  }
      field_name_d = field_name.downcase.strip
      is_checked = tag_array.include?(field_name_d)
    
      checked_option={field_name=>is_checked}
    
      #  the_object_class = field_pointer.class.name.downcase
      the_object_class = "checked_option"
    
      puts("tag_list_name:#{tag_list_name}, tag_name: #{tag_name}, tag_array1: #{tag_array1.inspect}, tag_array: #{tag_array}")
    
      if include_id then
      else
        return_value =(
          form_tag({:action => "update_checkbox_tag", :id=>field_pointer.id, :field=>field_name,:tag_id=>tag_id, :tag_name=>tag_name} , :remote => true) do
            check_box_tag("#{field_name}]", field_pointer.id, is_checked,html_options)+ field_name
            #check_box(the_object_class, field_name,html_options,"1","0")+ field_name
            #t.check_box(field_pointer.class)
          end)   
        #check_box_tag("#{field_name}]", field_pointer.id, is_checked, html_options.merge({
        #      :onchange => "#{remote_function(:url  => {:action => "update_checkbox_tag", :id=>field_pointer.id, :field=>field_name,:tag_id=>tag_id, :tag_name=>tag_name},
        #     :with => "'current_status='+checked")}"}))+field_name
      end
      return return_value.html_safe
    end
  
    def ajax_select(field_name, field_object, field_pointer, value_list, prompt='Please Select...', html_options={})
      puts(" - - - - - - - - - -  - - - - - - - - - - -  -  - - - ")
      puts(field_name, field_object, field_pointer.class, value_list.inspect)
      puts("Settings.send(field_name): '#{Settings.send(field_name)}'")
      # puts("field_pointer[field_name]: '#{field_pointer[field_name]}'")
      if (field_object == "settings") then
        found_item = value_list.index{|a| a[1]== Settings.send(field_name) }
        puts("found_item: '#{found_item}'")
        # html_options==nil ? html_options={:class=>"ui-ajax-settings-select", "data-path"=>url_for(request.original_url).to_s } : ""
        html_options = html_options.merge({:class=>"ui-ajax-settings-select", "data-path"=>url_for(request.original_url).to_s ,"data-attribute"=>field_name, "data-object"=>field_object}   )
        select_tag(field_name, options_for_select(value_list, Settings.send(field_name)), html_options)
      elsif (field_object == "cart") then
        found_item = value_list.index{|a| a[1]== @cart.send(field_name) }
        puts("@CART = #{@cart.inspect}")
        puts("found_item: '#{found_item}'")
        # html_options==nil ? html_options={:class=>"ui-ajax-cart-select", "data-path"=>url_for(field_pointer).to_s } : ""
        html_options = html_options.merge({:class=>"ui-ajax-cart-select", "data-path"=>url_for(field_pointer).to_s ,"data-attribute"=>field_name, "data-object"=>field_object})
        select_tag(field_name, options_for_select(value_list, @cart.send(field_name)), html_options)
      else
      
        html_options = html_options.merge({"data-path"=>url_for(field_pointer).to_s ,"data-id"=>field_pointer.id ,"data-attribute"=>field_name, "data-object"=>field_object}) rescue {}
        html_options[:class] = html_options[:class] + " ui-ajax-select" rescue "ui-ajax-select"
      
        # html_options==nil ? html_options={:class=>"ui-ajax-select", "data-path"=>url_for(field_pointer).to_s ,"data-id"=>field_pointer.id} : ""
       
        select(field_object,"#{field_name}",  options_for_select(value_list, field_pointer[field_name]),{ :prompt => prompt}, html_options )
      end
    

    end
  
     
    def generate_grid_tabnav(*args)
      html_options      = args.first || {}
      icon_list = args.second || {}
    
      grid_div_class = html_options[:grid_div_class].blank? ? "" : ("class='" + html_options[:grid_div_class]+"'")
      grid_div_id = html_options[:grid_div_id].blank? ? "" : ("id='" + html_options[:grid_div_id]+"'")
  
      grid_ul_class = html_options[:grid_ul_class].blank? ? "" : ("class='" + html_options[:grid_ul_class]+"'")
      grid_ul_id = html_options[:grid_ul_id].blank? ? "" : ("id='" + html_options[:grid_ul_id]+"'")
   
      grid_li_class = html_options[:grid_li_class].blank? ? "" : (html_options[:grid_li_class])
   
      out = "" 
      out << "<div #{grid_div_class} #{grid_div_id}>"
      out << "<ul #{grid_ul_class} #{grid_ul_id}>"
      icon_list.each  do |item|
        additional_args = item[:additional_args] ||{}
        additional_params = item[:additional_params] ||{}

        window_type = item[:window_type] || ""
        
        format_args = item[:format].blank? ? {} : {:format=>item[:format]}
        
        out << tab_link(navigation_icon(item[:name],item[:icon]),{:controller=>item[:controller], :action=>item[:action], :request_type=>"window", :window_type=>window_type, :role=>item[:role]}.merge!(additional_args).merge!(format_args), {:tooltip=> item[:tooltip], :name=>item[:name].gsub(/ /, '-')  ,:class=>grid_li_class, :remote=>true}.merge!(additional_params))
      end
    
      out << "</ul>"
      out << "</div>"
    
      return out.html_safe
    
    end
  
  
    def tab_link(*args, &block)
      if block_given?
        options      = args.first || {}
        html_options = args.second
        concat(link_to(capture(&block), options, html_options))
      else
        name         = args.first
        options      = args.second || {}
        html_options = args.third
      end
    
      if options[:controller].blank? then
        the_controller_name = params[:controller]
      else
        the_controller_name = options[:controller] 
      end
    
      the_action_name = options[:action]
      # puts(the_controller_name, the_action_name)

      if session[:user_id] then
        user =  User.find_by_id(session[:user_id])

        if options[:role].blank? or user.roles.map {|i| i.name }.include?(options[:role]) then
          if user.roles.detect{|role|
              role.rights.detect{|right|
                ((right.action == the_action_name)|(right.action == "*")|(right.action.include? the_action_name)) && right.controller == the_controller_name
              }
            } 
            #  puts("html_options[:order]:  #{html_options[:order]}")
        
            return("<li id='#{html_options[:name].gsub(/ /,'-')}' class='hidden #{options[:role].to_s.downcase}' title='#{html_options[:tooltip].to_s}'>" + link_to(*args,&block) + "</li>").html_safe
     
          else 
            return ""
          end
        else
          return ""
        end

      end
    end

    def tab_link_to(*args, &block)
      if block_given?
        options      = args.first || {}
        html_options = args.second
        concat(link_to(capture(&block), options, html_options))
      else
        name         = args.first
        options      = args.second || {}
        html_options = args.third
      end
    
      if options[:controller].blank? then
        the_controller_name = params[:controller]
      else
        the_controller_name = options[:controller] 
      end
    
      the_action_name = options[:action]
      # puts(the_controller_name, the_action_name)

      if session[:user_id] then
        user =  User.find_by_id(session[:user_id])

        if user.roles.detect{|role|
            role.rights.detect{|right|
              ((right.action == the_action_name)|(right.action == "*")|(right.action.include? the_action_name)) && right.controller == the_controller_name
            }
          }

          add_tab do |t|
            t.named name
            t.titled the_controller_name
            t.links_to :controller => the_controller_name, :action =>  the_action_name
          end
          #return_value = the_tab.create(the_controller_name, name) do
          # render :controller => the_controller_name, :action =>  the_action_name
          #  link_to(*args,&block)
          #end
          return
        else
          return ""
        end

        #  url = url_for(options)

        #  if html_options
        #    html_options = html_options.stringify_keys
        #    href = html_options['href']
        #    convert_options_to_javascript!(html_options, url)
        #    tag_options = tag_options(html_options)
        #  else
        #    tag_options = nil
        #  end

        #  href_attr = "href=\"#{url}\"" unless href
        #  "<a #{href_attr}#{tag_options}>#{name || url}</a>"
        # end

      end
    end
     
    def navigation_icon(name, icon='')
    
      icon = icon.blank? ? name : icon
    
      out = ""
     
      out << "<div class='navigation-icon'>"
      out << image_tag("interface/system_icons/"+icon.downcase+".png", {:class=>"navigation-image"})
      out << "<div class='navigation-icon-name'>"
      out << name
      out << "</div>"
      out << "<div id='ajax-wait'>"
      out << image_tag("cloud/cloud-ajax-loader.gif", {:class=>"ajax-wait", :style=>"display:none;"})
      out << "</div>"
      out << "</div>"

    
      return out.html_safe

    end
  
    def check_permissions(the_action_name,the_controller_name)
 
      user =  User.find_by_id(session[:user_id])

      return user.roles.detect{|role|
        role.rights.detect{|right|
          ((right.action == the_action_name)|(right.action == "*")|(right.action.include? the_action_name)) && right.controller == the_controller_name
        }
      }
    end
  
  
    def create_dialog_settings(dialog_name, dialog_width, dialog_height)
      out = ""
      out << "<div class='hidden-item'>"
      out << "<div id='as_window'>#{params[:request_type]=='window'}</div>"
      out << "<div id='dialog-height'>#{dialog_height}</div>"
      out << "<div id='dialog-width'>#{dialog_width}</div>"
      out << " <div id='dialog-name'>#{dialog_name}</div>"
      out << "</div>"
      return out.html_safe
    end
  
    def ajax_select_combo(field_name, field_object, field_pointer, value_list, prompt='Please Select...', html_options=nil)
        
      html_options==nil ? html_options={} : ""
    
      select(field_object,"#{field_name}", value_list,{ :prompt => prompt}, {"data-id"=>field_pointer.id,
        }.merge(html_options)
      ).html_safe

    end
    
    
    def build_pane_additions()
     out = ""
     panes_to_load = SilverwebCms::Config.USER_PANES()
     if panes_to_load.size > 0 then
       panes_to_load.each do |pane|
          out <<  (render :partial => ("silverweb_cms/" + pane + ".html"))
       end 
     end
     return out.html_safe
    end
    
    
    def build_site_pane_additions()
     out = ""
     panes_to_load = SilverwebCms::Config.SITE_PANES()
     if panes_to_load.size > 0 then
       panes_to_load.each do |pane|
          out <<  (render :partial => ("silverweb_cms/" + pane + ".html"))
       end 
     end
     return out.html_safe
    end
  end
