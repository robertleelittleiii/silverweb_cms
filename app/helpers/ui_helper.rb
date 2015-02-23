  module UiHelper
#  This will autoload css files based on the controller and/or action

  def controller_stylesheet_link_tag
    stylesheet = "#{params[:controller]}.css"
    
    stylesheetaction = "#{params[:controller]}/#{params[:action]=="index" ? "index" : params[:action]}.css"
    stylesheet_return = ""
  
        puts("stylesheet action path: #{stylesheetaction}")
        puts("real path: #{asset_path(stylesheetaction)}")
       # puts("the link tag #{stylesheet_link_tag(stylesheet)}")
       puts("the second link tag: #{stylesheet_link_tag stylesheetaction}")
    
    # if File.exists?(File.join(Rails.root, '/assets/stylesheets', stylesheet))
      stylesheet_return = stylesheet_link_tag stylesheet rescue ""
    #end
    
    #if File.exists?(File.join(Rails.root, '/assets/stylesheets', stylesheetaction))
      stylesheet_return = stylesheet_return + " " + (stylesheet_link_tag stylesheetaction) rescue ""
    #end
    
    return stylesheet_return.html_safe if not stylesheet_return.blank?
    
  end
  
  #  This will autoload javascript files based on the controller and/or action 

  def controller_javascript_include_tag
    
    javascript = "#{params[:controller]}.js"

    javascriptaction = "#{params[:controller]}/#{params[:action]=="index" ? "index" : params[:action]}.js"
    
    puts("javascript action path: #{javascriptaction}")
    javascript_return = ""
    
    puts("real path: /assets/#{javascriptaction}")
       
    
    
    # if File.exists?(File.join(Rails.root, '/assets/javascripts', javascript))
     javascript_return = javascript_include_tag(javascript) rescue ""
   #  end

   # if File.exists?(File.join(Rails.root, '/assets/javascripts', javascriptaction))
      javascript_return = javascript_return + " " + (javascript_include_tag(javascriptaction))rescue ""
   # end
    
    return javascript_return.html_safe if not javascript_return.blank?

  end
  
   def best_in_place(object, field, opts = {})
    logger.info("best_in_place")
    logger.info(opts[:class])
  
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
    if opts[:type] == :checkbox
      fieldValue = !!object.send(field)
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
    
    #fix for rails settings gem
    object_class_name = object.class.to_s.gsub("::", "_").underscore
    object_class_name = (object_class_name == "active_support_hash_with_indifferent_access" ? "settings" : object_class_name)
    puts("object-class-name in bestinplace: #{object_class_name}")
    
    out = "<div class='best_in_place " + extraclass
    out << " id='best_in_place_#{object_class_name}_#{field}'"
    out << " data-url='#{opts[:path].blank? ? url_for(object).to_s : url_for(opts[:path])}'"
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
    
    if not opts[:format_type].blank?  then
      case opts[:format_type] 
      when "time"
        value =  Time.parse(value.to_s).strftime(opts[:format_string]) if not value.blank?
      when "date"
        value =  Date.parse(value.to_s).strftime(opts[:format_string]) if not value.blank?
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
    out << "</div>"
    
    if !opts[:validation_message].blank? then
      out << "<lable data-attribute='#{field}' class='best_in_place_validation'>"
      out << opts[:validation_message]
      out << "</lable>"
    end
    
    return out
  end
  
  def editablefieldcreate(field_name,field_pointer, empty_message="Click me to add content!", opts = {})
 
    if field_pointer.blank? then
      flash[:notice] = field_name + " not found !!"
      return "ERROR"
    end
    if opts[:divclass].nil? then
      divClass='class="myaccountcontentitem"'
    else
      divClass=opts[:divclass]
    end rescue divClass='class="myacountcontentitem"'
  
    if (field_pointer[field_name].class == String and field_pointer[field_name].length > 85) or opts[:force_textarea] then
      ('<div id="field_'+field_name.to_s + '"' + divClass + '>' +
          best_in_place(field_pointer, field_name, opts.merge(:type => :textarea, :nil => empty_message)).html_safe +
          '</div>').html_safe
    else 
      ('<div id="field_'+field_name.to_s + '"' + divClass + '>' +
          best_in_place(field_pointer, field_name, opts.merge(:type => :input, :nil => empty_message)).html_safe +
          '</div>').html_safe
    end
  end
  
  def editablecheckboxedit (field_name, field_pointer,field_title, opts = {})
  
    if field_pointer.blank? then
      flash[:notice] = field_name + " not found !!"
      return "ERROR"
    end
    if opts[:divclass].nil? then
      divClass='class="myaccountcontentitem"'
    else
      divClass=opts[:divclass]
    end rescue divClass='class="myacountcontentitem"'
    
      ('<div id="field_'+field_name.to_s + '"' + divClass + '>' +
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
  def create_group_checkbox_live(field_name, field_pointer, value_list, html_options={})
    
    return_value = ""
    
    value_list.each do |item|
      return_value =  return_value + editablecheckboxeditmulti(field_name, field_pointer,item, html_options)  
    end
    return content_tag(:div,return_value, html_options,false)
  end
  
  
  def editablecheckboxeditmulti (field_name, field_pointer ,field_title, html_options={},opts={} )

    db_field_name= field_name.split("-").first
    is_selected = field_pointer[db_field_name].split(",").include?(field_title) rescue false  
    
    if field_pointer.blank? then
      flash[:notice] = field_name + " not found !!"
      return "ERROR"
    end
    if opts[:divclass].nil? then
      divClass='class="myaccountcontentitem"'
    else
      divClass=opts[:divclass]
    end rescue divClass='class="myacountcontentitem"'
    
      ('<div id="field_'+field_name.to_s + '"' + divClass + '>' +
          best_in_place(field_pointer, field_name, opts.merge(:type => :checkbox)).html_safe +
          '</div>').html_safe
      
    #check_box_tag( "#{field_name}", field_title,is_selected , html_options.merge!({
    #      :onchange => "#{remote_function(:url  => {:action => "update_checkbox_multi", :id=>field_pointer.id, :field=>db_field_name ,:pointer_class=>field_pointer.class, :checkbox_value=>field_title},
    #      :with => "'current_status='+checked")}"}))+field_title

  end
  
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
  
     def ajax_select(field_name, field_object, field_pointer, value_list, prompt='Please Select...', html_options=nil)
        
    html_options==nil ? html_options={} : ""
    
    select(field_object,"#{field_name}", value_list,{ :prompt => prompt}, {"data-id"=>field_pointer.id,
      }.merge(html_options)
    )

  end
  
     
  
end
