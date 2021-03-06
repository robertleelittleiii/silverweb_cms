module SecurityHelper
  
  def login_div(contents=false)
    
    out = ""
   
    out << "<div id='security-div'>" if not contents
    if session[:user_id] then
      out << "<div class='hidden-item' id='logged-in'>true</div>"
      out << link_to('sign out',{ :controller => :site, :action =>'logout_ajax'}, :remote=>true, :id=>"sign-out-button", :class=>"sites-system-link" )
      out << "<div id='my-account' class='sites-system-link'>my account</div>" #link_to('my account',"#",:id=>"my-account", :class=>"site-system-link")
    else
      out << "<div class='hidden-item' id='logged-in'>false</div>"
      out << "<div id='sign-in-button' class='sites-system-link'>sign in</div>"
    end
    out << "</div>"   if not contents
    return out.html_safe
    
  end
end