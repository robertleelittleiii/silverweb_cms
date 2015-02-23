module PagesHelper
  
  def get_page_style_sheet
    if @page.blank? then
        return ""
      else
        return  stylesheet_link_tag @page.page_style  rescue ""
      end
  end
  
  def page_attr_display(page,full_screen="false", has_slider="false")
    returnval=""
    returnval="<div id=\"attr-pages\" class=\"hidden-item\">"
    returnval=returnval+"<div id=\"full-screen\">"+(page.full_screen.to_s rescue full_screen)+"</div>"
    returnval=returnval+"<div id=\"has-slider\">"+(page.has_slider.to_s rescue has_slider)+"</div>"

    returnval=returnval + "</div>"
    return returnval.html_safe
 
  end
  
  
end
