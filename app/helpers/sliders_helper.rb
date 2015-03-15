module SlidersHelper


  def slider_delete(slider)

    returnval=""
    returnval = link_to(image_tag("interface/Button-Delete.png", :border=>"0",:id=>"delete-button") , slider, :class=>"delete_slider",  data: { confirm: "Are you sure?" }, :method => :delete , :remote=>true)

    return returnval
  end

end
