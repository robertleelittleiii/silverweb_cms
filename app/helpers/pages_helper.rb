module PagesHelper
  
  def get_page_name
    out=""
    if not @category_id.blank?
      puts("Category selected for get_page_name")
      out << @category_id
    else
      puts("Page.name selected for get_page_name")

      out << @page.name rescue @page_name rescue ""
    end
    puts("out: #{out}")

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
    if @page.blank? then
        return ""
      else
        return  stylesheet_link_tag @page.page_style  rescue ""
      end
  end
  
  def page_info(page)
    returnval = "<div id=\"attr-pages\" class=\"hidden-item\">"
    returnval << "<div id=\"page-id\">"+(page.id.to_s rescue "-1")+"</div>"
    
    returnval=returnval + "</div>"
    return returnval.html_safe
 
  end
  
  
end
