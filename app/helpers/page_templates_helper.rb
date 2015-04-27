module PageTemplatesHelper
 
  def page_template_info(page_template)
    returnval = "<div id=\"attr-pages\" class=\"hidden-item\">"
    returnval << "<div id=\"page-template-id\">"+(page_template.id.to_s rescue "-1")+"</div>"
    
    returnval=returnval + "</div>"
    return returnval.html_safe
 
  end
  
  
end
