module TinymceHelper
  
  def tinymce_settings(setting_name=:default,opts={} )
  out = ""
  out << "<script>"+ "\n"
  out << "//<![CDATA[" + "\n"
  out << "tinymce_config = " + tinymce_configuration(setting_name,opts).to_javascript + "\n"
  out << "//]]>"+ "\n"
  out << "</script>"+ "\n"
  
    return out.html_safe
  end
  
end
#//<![CDATA[
#tinyMCE.init({
#selector: "textarea.tinymce-page",
#toolbar: ["save | newdocument fullpage | bold italic underline strikethrough | alignleft aligncenter alignright alignjustify | styleselect formatselect fontselect fontsizeselect | imagelibrary","cut copy paste | searchreplace | bullist numlist | outdent indent blockquote | undo redo | link unlink anchor image media code | insertdatetime preview | forecolor backcolor","table | hr removeformat | subscript superscript | charmap emoticons | print fullscreen | ltr rtl | spellchecker | visualchars visualblocks nonbreaking template pagebreak restoredraft"],
#plugins: "image_library,imagelibrary,image,link,table,advlist,anchor,autolink,autosave,charmap,codemirror,colorpicker,contextmenu,directionality,emoticons,example,example_dependency,fullscreen,hr,image,importcss,insertdatetime,layer,legacyoutput,link,lists,media,nonbreaking,noneditable,pagebreak,paste,preview,print,save,searchreplace,spellchecker,tabfocus,table,template,textcolor,textpattern,visualblocks,visualchars,wordcount",
#relative_urls: false,
#link_list: "/pages/link_list.text",
#image_advtab: true,
#image_list: [{"title":"My image 1","value":"http://www.tinymce.com/my1.gif"},{"title":"My image 2","value":"http://www.moxiecode.com/my2.gif"}],
#mode: "exact",
#save_onsavecallback: "mysave",
#height: "375",
#width: "950",
#init_instance_callback: "tinyMcePostInit"
#});
#//]]>