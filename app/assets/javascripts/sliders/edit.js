/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

var global_slider_editor_hold = "";
var sliders_edit_callDocumentReady_called = false;

$(document).ready(function() {
    if (!sliders_edit_callDocumentReady_called)
    {
        sliders_edit_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        }
        else
        {
            sliders_edit_callDocumentReady();
        }
    }
});

function sliders_edit_callDocumentReady() {
    $("#slider-tabs").tabs();
    $(".best_in_place").best_in_place();
    ui_ajax_select();
    $("a.button-link").button();
    tinyMCE.init(tinymce_config);

    // alert("im here");
    // setTimeout(function(){bind_file_paste_to_upload_form();},2000); 
    
}

function tinyMcePostInit(inst) {
sliders_bind_file_paste_to_upload_form();
}

function mysave() {
    console.log("trigger save");
    tinymce.triggerSave();
    // $("#page-body-save").closest("form").trigger("submit");
    $("#slider_slider_content").parent().parent().closest("form").trigger("submit");

}



function sliders_bind_file_paste_to_upload_form()
{
    $("form#picture-paste-slider").fileupload({
        dataType: "json",
        pasteZone:  $("iframe#slider_slider_content_ifr").contents().find("body"),
        add: function (e, data) {
            file = data.files[0];
            data.context = $(tmpl("template-upload", file));
            // $("div.progress").progressbar();
            // $('#pictures').prepend(data.context);
            var jqXHR = data.submit()
                    .success(function (result, statusText, jqXHR) {

//                     console.log("------ - fileupload: Success - -------");
//                      console.log(result);
//                     console.log(statusText);
//                     console.log(jqXHR);
//
//                     console.log(JSON.stringify(jqXHR.responseJSON["attachment"]));
//
//                       console.log(typeof (jqXHR.responseText));
//                        
                        
// specifically for IE8. 
                        if (typeof (jqXHR.responseText) == "undefined") {
                           top.tinymce.activeEditor.undoManager.undo();
                           setUpPurrNotifier("Notice", jqXHR.responseJSON["attachment"][0]);
                            data.context.remove();
                        }
                        else
                        {
                            top.tinymce.activeEditor.undoManager.undo();
                          //  console.log(result.image.url)
                            image_tag = "<img src='"+ result.image.url + "'/>"
                            top.tinymce.activeEditor.insertContent(image_tag);
                            console.log("success");
                            //  render_pictures();
                        }

                    })
                    .error(function (jqXHR, statusText, errorThrown) {
//                         console.log("------ - fileupload: Error - -------");
//                        console.log(jqXHR.status);
//                        console.log(statusText);
//                        console.log(errorThrown);
//                        console.log(jqXHR.responseText);
                        if (jqXHR.status == "200")
                        {
                            //render_pictures();
                        }
                        else
                        {
                            //var obj = jQuery.parseJSON(jqXHR.responseText);
                            // console.log(typeof obj["attachment"][0])
                            //setUpPurrNotifier("info.png", "Notice", obj["attachment"][0]);
                            // data.context.remove();
                        }
//                        if (jqXHR.statusText == "success") {
//                            render_pictures();
//                            // It succeeded and we need to update the file list.
//                        }
//                        else {
//                            var obj = jQuery.parseJSON(jqXHR.responseText);
//                            setUpPurrNotifier("info.png", "Notice", obj["attachment"][0]);
//                            data.context.remove();
//                        }

                    })
                    .complete(function (result, textStatus, jqXHR) {
//                        console.log("------ - fileupload: Complete - -------");
//                        console.log(result);
//                        console.log(textStatus);
//                        console.log(jqXHR);
                    });
        },
        progress: function (e, data) {
            if (data.context)
            {
               // progress = parseInt(data.loaded / data.total * 100, 10);
                //data.context.find('.bar').css('width', progress + '%');
            }
        },
        done: function (e, data) {
            console.log(e);
            console.log(data);
            // data.context.text('');
        }
    }).bind('fileuploaddone', function (e, data) {
        console.log(e);
        console.log(data);
       // data.context.remove();
        //data.context.text('');
    }).bind('fileuploadpaste', function (e, data) {
        /* ... */
        image_tag = "<img src='/assets/interface/ajax-loader-big.gif'/>"
        top.tinymce.activeEditor.undoManager.add();
        top.tinymce.activeEditor.insertContent(image_tag);
        top.tinymce.activeEditor.undoManager.add();

        // assets/interface/ajax-loader.gif
        console.log("paste event.")
        
        
    })
}
function initTinyMCESlider() {
      tinyMCE.init(tinymce_config)
  }
  
  $(document).off('focusin').on('focusin', function (e) {
    if ($(event.target).closest(".mce-window").length) {
        e.stopImmediatePropagation();
        console.log("worked!");
    }
});