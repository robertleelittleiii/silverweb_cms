module FlexsliderHelper
  
  def show_flexslider_gallary(page, effect="slide", slider_id="flexslider")
    if not page.blank? and page.has_slider then
      
      # info for javascript 
      
      returnval = "<div class='slider-container' id='" + slider_id + "'>"
      returnval = returnval + "<div class=\"hidden-item\"> \n"
      returnval =  returnval + "<div id='slider-width'>#{page.slider_width}</div> \n"
      returnval =  returnval + "<div id='slider-height'>#{page.slider_height}</div> \n"
      returnval =  returnval + "<div id='slider-nav'>#{page.slider_show_nav}</div> \n"
#      returnval =  returnval + "<div id='slider-effect'>#{effect}</div> \n"
      returnval =  returnval + "</div> \n"
      
      returnval = returnval + "<div class='flexslider'> \n"
      returnval = returnval + "<ul class='slides'> \n"

#     maybe not needed.
#                           if slide_count == 0 then
#          returnval =  returnval + "<li> \n"
#        else
#          returnval =  returnval + "<div class='flexslider' style='display:none'>"
#        end

      page.sliders.active.each_with_index do |slider, slide_count| 
        puts("slide count #{slide_count}")
        returnval = returnval + "<li> \n"
        
        returnval = returnval + "<div class='hidden-item'>"
        returnval = returnval + "<div id='slider-id'>" + slider.id.to_s + "</div>"
        returnval = returnval + "</div>"
        
        returnval = returnval + slide_edit_div(slider)
        returnval =  returnval +  "<div class='" + action_name + " slider-content-float'>" + slider.slider_content + "</div> \n"
        returnval =  returnval + "</li> \n"
      end
      returnval =  returnval + "</ul> \n"
      returnval =  returnval + "</div> \n"
      returnval =  returnval + "</div> \n"

      return returnval.html_safe
    else
      return "" 
    end rescue ""
  end  
  
  
  
  
end
