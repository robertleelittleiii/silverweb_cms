module SiteHelper
  #<div id="slides">
  #  <div class="slides_container">
  #    <div>
  #      <h1>Slide 1</h1>
  #      <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>
  #    </div>
  #    <div>
  #      <h1>Slide 2</h1>
  #      <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>
  #    </div>
  #    <div>
  #      <h1>Slide 3</h1>
  #      <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>
  #    </div>
  #    <div>
  #      <h1>Slide 4</h1>
  #      <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p>
  #    </div>
  #  </div>
  #</div>
  #        
  
  def display_html(data)
    data.html_safe
  end
  
  def popup_page_link(page_name, the_class=nil, the_id=nil)
    @page = Page.where(:title=> page_name).first
    if @page .blank? then
      return "Page #{page_name} Not Found!!"
    end
    returnval = ""
    returnval = returnval + link_to(page_name, {:controller=>"site", :action=>:show_page, :id=>@page.id}, {:class=>the_class, :id=>the_id})
    return returnval.html_safe
  end
  
  def show_apple_carousel(page,item_count)
    if not page.blank? and page.has_slider then
      returnval = ""
      returnval = returnval + "<div class=\"hidden-item\">"
      returnval =  returnval + "<div id='slider-width'> #{page.slider_width} </div>"
      returnval =  returnval + "<div id='slider-height'> #{page.slider_height} </div>"
      returnval =  returnval + "<div id='slider-nav'> #{page.slider_show_nav} </div>"

      returnval =  returnval + "</div>"
      
      returnval = returnval + "<div class=\"bouncemenu\">"
      returnval =  returnval + "<div class=\"bounceholder\" >"
      
      bounceTabs = "<div class=\"bouncetabs\">"

      page.sliders.active.each_with_index do |slider, slide_count| 
        puts("slide count #{slide_count}")
        
        if(slide_count % item_count) == 0 
          if slide_count  > 1
            returnval =  returnval +  "</ul>"
          end  
          returnval =  returnval +  "<ul>"
          bounceTabs = bounceTabs + "<a href=\"#\">"+ ((slide_count/item_count) + 1).to_s + "</a>"

        end  
        li_default_style = ' style="left: ' + (((slide_count+1)*1000)).to_s  + 'px;"'
        #        returnval =  returnval + "<h1>" + slider.slider_name + "</h1>"
        returnval =  returnval +  "<li class='" + action_name + " slider-content-float'" + li_default_style + ">" + slider.slider_content 
        returnval = returnval + slide_edit_div(slider)

        returnval = returnval +  "</li>"
        
      end
      bounceTabs = bounceTabs + "</div>"
      returnval =  returnval + "</div>"

      returnval =  returnval + "</div>"
      if page.slider_show_nav then
        returnval = returnval + bounceTabs
      end
    
      return returnval.html_safe
    else
      return "" 
    end rescue ""
  end  
  
  def show_slider_gallary_v2(page)
    if not page.blank? and page.has_slider then
      returnval = ""
      returnval = returnval + "<div class=\"hidden-item\">"
      returnval =  returnval + "<div id='slider-width'> #{page.slider_width} </div>"
      returnval =  returnval + "<div id='slider-height'> #{page.slider_height} </div>"
      returnval =  returnval + "<div id='slider-nav'> #{page.slider_show_nav} </div>"
      returnval =  returnval + "</div>"
      
      returnval = returnval + "<div id=\"slides\">"
      returnval =  returnval + "<div class=\"slides_container\" >"
      page.sliders.active.each_with_index do |slider, slide_count| 
        puts("slide count #{slide_count}")
        if slide_count == 0 then
          returnval =  returnval + "<div class='slider-content'>"
        else
          returnval =  returnval + "<div class='slider-content' style='display:none'>"
        end
        
        #        returnval =  returnval + "<h1>" + slider.slider_name + "</h1>"
        returnval = returnval + slide_edit_div(slider)
        returnval =  returnval +  "<div class='" + action_name + " slider-content-float'>" + slider.slider_content + "</div>"
        
        returnval =  returnval + "</div>"
      end
      returnval =  returnval + "</div>"

      
      if page.slider_show_nav then
        returnval =  returnval +  "<a href=\"#\" class=\"prev-slide\"><img src=\"/images/interface/arrow-prev.png\" width=\"12\" height=\"16\" alt=\"Arrow Prev\"></a>"

        returnval =  returnval + "<a href=\"#\" class=\"next-slide\"><img src=\"/images/interface/arrow-next.png\" width=\"12\" height=\"16\" alt=\"Arrow Next\"></a>"
      end

      returnval =  returnval + "</div>"
   
    
      return returnval.html_safe
    else
      return "" 
    end rescue ""
  end  

  def show_slider_gallary_v3(page, effect="fade")
    if not page.blank? and page.has_slider then
      
      returnval = ""
      returnval = returnval + "<div class=\"hidden-item\"> \n"
      returnval =  returnval + "<div id='slider-width'>#{page.slider_width}</div> \n"
      returnval =  returnval + "<div id='slider-height'>#{page.slider_height}</div> \n"
      returnval =  returnval + "<div id='slider-nav'>#{page.slider_show_nav}</div> \n"
      returnval =  returnval + "<div id='slider-effect'>#{effect}</div> \n"
      returnval =  returnval + "</div> \n"
      
      returnval = returnval + "<div id=\"slides3\"> \n"
      page.sliders.active.each_with_index do |slider, slide_count| 
        puts("slide count #{slide_count}")
        if slide_count == 0 then
          returnval =  returnval + "<div class='slider-content'> \n"
        else
          returnval =  returnval + "<div class='slider-content' style='display:none'>"
        end
        returnval = returnval + "<div class='hidden-item'>"
        returnval = returnval + "<div id='slider-id'>" + slider.id.to_s + "</div>"
        returnval = returnval + "</div>"
        
        #        returnval =  returnval + "<h1>" + slider.slider_name + "</h1>"
        returnval = returnval + slide_edit_div(slider)
        returnval =  returnval +  "<div class='" + action_name + " slider-content-float'>" + slider.slider_content + "</div> \n"
        returnval =  returnval + "</div> \n"
      end
      returnval =  returnval + "</div> \n"
      return returnval.html_safe
    else
      return "" 
    end #rescue ""
  end  
  
  def show_nav_gallary(page,top_lead_text="", bottom_lead_text="", effect="fade")
    if not page.blank? and page.has_slider then
              
      returnval = ""
      returnval = returnval + "<div class=\"hidden-item\"> \n"
      returnval =  returnval + "<div id='slider-width'>#{page.slider_width}</div> \n"
      returnval =  returnval + "<div id='slider-height'>#{page.slider_height}</div> \n"
      returnval =  returnval + "<div id='slider-nav'>#{page.slider_show_nav}</div> \n"
      returnval =  returnval + "<div id='slider-effect'>#{effect}</div> \n"
      returnval =  returnval + "</div> \n"
      
      returnval = returnval + "<div id=\"nav-gallery\"> \n" # start nav-gallery
      page.sliders.active.each_with_index do |slider, slide_count| 
        
        bottom_text = slider.slider_tag_line_two.blank? ? bottom_lead_text : slider.slider_tag_line_two
        bottom_link_text = slider.slider_url.blank? ? ("<div class='#{slider.slider_button_color.to_s}'>" + bottom_text + "</div>") : link_to(bottom_text,slider.slider_url, :class=>slider.slider_button_color)
        slider_link_text = slider.slider_url.blank? ? (slider.slider_name) : link_to(slider.slider_name,slider.slider_url, :class=>slider.slider_button_color)

        
        
        puts("slide count #{slide_count}")
        returnval =  returnval + "<div class='nav-item'> \n" # start nav-item
        returnval = returnval + slide_edit_div(slider)

        #        returnval =  returnval + "<h1>" + slider.slider_name + "</h1>"
        returnval =  returnval +  "<div class='nav-content-overlay'> \n"
        #returnval =  returnval + "<div class='nav-content-overlay-top'>" + (slider.slider_tag_line_one.blank? ? top_lead_text : slider.slider_tag_line_one)  + "</div> \n"
        returnval =  returnval +  "<div class='nav-content-overlay-title'><span>" + slider_link_text + "</span></div> \n"
        # => returnval =  returnval + "<div class='nav-content-overlay-bottom'>" + bottom_link_text + "</div> \n"
        returnval =  returnval +  "</div> \n"     # end nav-item

        returnval =  returnval +  "<div class='" + action_name + " nav-content-float'>" + slider.slider_content + "</div> \n"
        
        returnval =  returnval + "</div> \n"     # end nav-item

      end
      returnval =  returnval + "</div> \n"   #end nav-gallery
      return returnval.html_safe
    else
      return "" 
    end #rescue ""
  end 

  def show_title_not_null(title, value, cell_params)
    returnval = ""
    returnval = returnval +'<td align="right" ><b>' + (value.blank? ? "" : title) + '</b></td>'
    returnval = returnval + '<td '+cell_params+'> ' + value + '</td>'
    return returnval.html_safe
  end
  
  def slide_edit_div(slide)
    returnval=""
    if session[:user_id] then
      user=User.find(session[:user_id])
      if user.roles.detect{|role|((role.name=="Admin") | (role.name=="Site Owner"))} then
        returnval="<div id=\"edit-slider\">"
        returnval=returnval+image_tag("interface/edit.png",:border=>"0", :class=>"imagebutton", :title => "Edit this Slider")
        returnval=returnval + "</div>"
      end
    end
    return returnval.html_safe
  end  
  
  def admin_active
    returnval="false"
    if session[:user_id] then
      user=User.find(session[:user_id])
      if user.roles.detect{|role|((role.name=="Admin") | (role.name=="Site Owner"))} then
        returnval="true"
      end
    end
    return returnval.html_safe
  end
  

  def page_edit_div(page, div_id="")
    returnval=""
    begin
      if session[:user_id] then
        user=User.find(session[:user_id])
        if user.roles.detect{|role|((role.name=="Admin") | (role.name=="Site Owner"))} then
          returnval = "<div id=\""+ (div_id=="" ? "edit-pages" : div_id) + "\" >"
          returnval << "<div id='page-id' class='hidden-item'>#{page.id}</div>"
          returnval << image_tag("interface/edit.png",:border=>"0", :class=>"imagebutton", :title => "Edit this Page") # link_to(image_tag("interface/edit.png",:border=>"0", :class=>"imagebutton", :title => "Edit this Page"),:controller => 'pages', :id =>page.id ,  :action => 'edit')
          returnval << "</div>"
        end
      end
    rescue
    end
    return returnval.html_safe

  end
   
  def page_attr_display(page,full_screen="false", has_slider="false")
    returnval=""
    returnval << "<div id=\"attr-pages\" class=\"hidden-item\">"
    returnval << "<div id=\"page-id\">"+(page.id.to_s rescue "n/a")+"</div>"
    returnval << "<div id=\"full-screen\">"+(page.full_screen.to_s rescue full_screen)+"</div>"
    returnval << "<div id=\"has-slider\">"+(page.has_slider.to_s rescue has_slider)+"</div>"

    returnval << "</div>"
    return returnval.html_safe
 
  end
  
  def sizelabel(product)
    returnval = product.size_label.blank? ? "SIZE:" : product.size_label
    return returnval.html_safe
  end
  
  def show_meta_page_data(page)
    returnval = ""
    if not page.blank? then
      returnval << (page.meta_description.blank? ? "" : "<meta name='description' content='#{page.meta_description}'>")
      returnval << (page.meta_keywords.blank? ? "" : "<meta name='keywords' content='#{page.meta_keywords}'>")
      returnval << (page.meta_robot.blank? ? "" : "<meta name='robots' content='#{page.meta_robot}'>")
    end
    return returnval.html_safe
  end
end
