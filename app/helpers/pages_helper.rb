module PagesHelper
  
  def get_page_name
    out=""
    if not @category_id.blank?
      puts("Category selected for get_page_name")
      out = @category_id
    else
      puts("Page.name selected for get_page_name: '#{@page.inspect}', @page_name: '#{@page_name}'")
      puts("params: #{params.inspect}")
      out = @page.name rescue ((@page_name.blank? ? params[:page_name] : @page_name) rescue "")
   #  out << (@page.blank? ? (@page_name.blank? ? "n/a" : @page_name) : @page.name)

    end
    puts("out: '#{out}'")
    
    return out
  end
  
  def get_page_title
    if not @page_name.blank? then
      return @page_name
    else
      if @page.blank? then
        return ""
      else
        return  @page.title rescue "Page Title not Found"
      end
    end
  end
  
  def get_page_style_sheet
    begin
      if @page.blank? or @page.page_style.blank? then
        return ""
      else
        return stylesheet_link_tag("style_types/" + @page.page_style) rescue ""
      end
    rescue
      return ""
    end
  end
  
  def page_info(page,full_screen="false")
    returnval = "<div id=\"attr-pages\" class=\"hidden-item\">"
    returnval << "<div id=\"page-id\">"+(page.id.to_s rescue "-1")+"</div>"
    returnval << "<div id=\"full-screen\">"+(page.full_screen.to_s rescue full_screen)+"</div>"
    returnval << ((page.pop_up_page_link.blank? ? "" :"<div id=\"pop-up-page-link\">"+(page.pop_up_page_link.to_s ) rescue "" ) +"</div>")
    returnval=returnval + "</div>"
    return returnval.html_safe
 
  end
  
 
  
#  def page_attr_display(page,full_screen="false")
#    returnval=""
#    returnval="<div id=\"attr-pages\" class=\"hidden-item\">"
#    returnval=returnval+"<div id=\"full-screen\">"+(page.full_screen.to_s rescue full_screen)+"</div>"
#    returnval=returnval+ ((page.pop_up_page_link.blank? ? "" :"<div id=\"pop-up-page-link\">"+(page.pop_up_page_link.to_s ) rescue "" ) +"</div>")
#    returnval=returnval + "</div>"
#    return returnval.html_safe
# 
#  end
  
  
end
