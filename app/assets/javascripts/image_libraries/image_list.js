/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var picture_edit_dialog = "";
var picture_insert_dialog = "";

$(document).ready(function () {

    // alert("in here");
    // $("#tabs").tabs();
    bind_file_upload_to_upload_form();
    bind_paste_body_zone();
    bind_mouseover();
    initialize_edit_button();
    initialize_insert_image_button();
    activate_buttons();
});

//$(document).on('focusin', function(e) {
//    if ($(event.target).closest(".mce-window").length) {
//		e.stopImmediatePropagation();
//	}
//});

function activate_buttons() {
    
    $("div.ui-button a").button();
}
function bind_paste_body_zone(){
    
    $('body').fileupload({
    pasteZone: $('body')
});

}
function bind_mouseover()
{

    $("div.file-block")
            .unbind("mouseenter").mouseenter(function () {
                $(this).parent().find("div.hover-block").fadeIn();
                // console.log("fadeIn");
            })
            .unbind("mouseleave").mouseleave(function () {
                 $(this).parent().find("div.hover-block").fadeOut();
               //   console.log("fadeOut");
           });

//$("div.file-block").hover(function() {
//                //$(this).parent().find("div.hover-block").css('opacity','1');
//                console.log("hover-on");
//    },function(){
//                // $(this).parent().find("div.hover-block").css('opacity','0');
//                                 console.log("hover-off");
//
//    });

}
function render_pictures(picture_id) {
    $.ajax({
        dataType: "html",
        url: '/pictures/render_picture',
        cache: false,
        data: "id="+picture_id,
        success: function (data)
        {
            $("div#pictures").prepend(data).hide().fadeIn();
            bind_file_upload_to_upload_form();
            bind_mouseover();
            initialize_insert_image_button();
            initialize_edit_button();
            activate_buttons();
            
        }
    });

}

// binds the download attachment link for each attached file.

function bind_download_to_files()
{
    $("div.file-item div#logo-links").unbind("click");
    $("div.file-item div#logo-links").bind("click",
            function () {
                var href = $($(this)[0]).find('a').attr('href');
                window.location.href = href
            });
}

// bind the upload button using the fileupload javascirpt and gem.

function bind_file_upload_to_upload_form()
{
    bind_download_to_files();
    $("form#new_picture").fileupload({
        dataType: "json",
        add: function (e, data) {
            file = data.files[0];
            data.context = $(tmpl("template-upload", file));
            // $("div.progress").progressbar();
            $('#pictures').prepend(data.context);
            var jqXHR = data.submit()
                    .success(function (result, statusText, jqXHR) {

                        console.log("------ - fileupload: Success - -------");
                        console.log(result);
                        console.log(result.id);
                        console.log(statusText);
                        console.log(jqXHR);

                        console.log(JSON.stringify(jqXHR.responseJSON["attachment"]));

                        console.log(typeof(jqXHR.responseText));
// specifically for IE8. 
                        if (typeof (jqXHR.responseText) == "undefined") {
                            setUpPurrNotifier( "Notice", jqXHR.responseJSON["attachment"][0]);
                            data.context.remove();
                        }
                        else
                        {
                            render_pictures(result.id);
                        }

                    })
                    .error(function (jqXHR, statusText, errorThrown) {
                        // console.log("------ - fileupload: Error - -------");
                        // console.log(jqXHR.status);
                        // console.log(statusText);
                        // console.log(errorThrown);
                        // console.log(jqXHR.responseText);
                        if (jqXHR.status == "200")
                        {
                         //   render_pictures();
                        }
                        else
                        {
                            var obj = jQuery.parseJSON(jqXHR.responseText);
                            // console.log(typeof obj["attachment"][0])
                            setUpPurrNotifier( "Notice", obj["attachment"][0]);
                            data.context.remove();
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
                        // console.log("------ - fileupload: Complete - -------");
                        // console.log(result);
                        // console.log(textStatus);
                        // console.log(jqXHR);
                    });
        },
        progress: function (e, data) {
            if (data.context)
            {
                progress = parseInt(data.loaded / data.total * 100, 10);
                data.context.find('.bar').css('width', progress + '%');
            }
        },
        done: function (e, data) {
            // console.log(e);
            // console.log(data);
            data.context.text('');
        }
    }).bind('fileuploaddone', function (e, data) {
        // console.log(e);
        // console.log(data);
        data.context.remove();
        //data.context.text('');
    });
};


function initialize_insert_button()
        {
            $("a.insert-picture")
                    .bind("ajax:beforeSend", function(evt, xhr, settings) {
                 //alert("ajax:beforeSend");
            })
                    .bind("ajax:success", function(evt, data, status, xhr) {
                // alert("ajax:success");
                // edit_picture_dialog(data);
                 top.tinymce.activeEditor.insertContent(data);

                    })
                    .bind('ajax:complete', function(evt, xhr, status) {
                 //alert("ajax:complete");
            })
                    .bind("ajax:error", function(evt, xhr, status, error) {
                //  alert("ajax:error");

                var $form = $(this),
                        errors,
                        errorText;

                try {
                    // Populate errorText with the comment errors
                    console.log(xhr);
                    console.log(status);
                    console.log(error);
                    
                    errors = $.parseJSON(xhr.responseText);
                    console.log(errors);
                    
                } catch (err) {
                    // If the responseText is not valid JSON (like if a 500 exception was thrown), populate errors with a generic error message.
                    errors = {
                        message: "Please reload the page and try again"
                    };
                }
                var errorText;
                // Build an unordered list from the list of errors
                errorText = "<ul>";

                for (error in errors) {
                    console.log(error);
                    console.log(errors[error][0]);
                    errorText += "<li>" + error + ': ' + errors[error][0] + "</li> ";
                    console.log(errorText);
                }

                errorText += "</ul>";
                    console.log(errorText);

                // Insert error list into form
                setUpNotifier("error.png", "Warning", errorText);
            });

        }
        
  function initialize_insert_image_button()
        {
            $("a.insert-image").unbind()
                    .bind("ajax:beforeSend", function(evt, xhr, settings) {
                 //alert("ajax:beforeSend");
            })
                    .bind("ajax:success", function(evt, data, status, xhr) {
                // alert("ajax:success");
                insert_picture_dialog(data);
                
            })
                    .bind('ajax:complete', function(evt, xhr, status) {
                 //alert("ajax:complete");
            })
                    .bind("ajax:error", function(evt, xhr, status, error) {
                //  alert("ajax:error");

                var $form = $(this),
                        errors,
                        errorText;

                try {
                    // Populate errorText with the comment errors
                    console.log(xhr);
                    console.log(status);
                    console.log(error);
                    
                    errors = $.parseJSON(xhr.responseText);
                    console.log(errors);
                    
                } catch (err) {
                    // If the responseText is not valid JSON (like if a 500 exception was thrown), populate errors with a generic error message.
                    errors = {
                        message: "Please reload the page and try again"
                    };
                }
                var errorText;
                // Build an unordered list from the list of errors
                errorText = "<ul>";

                for (error in errors) {
                    console.log(error);
                    console.log(errors[error][0]);
                    errorText += "<li>" + error + ': ' + errors[error][0] + "</li> ";
                    console.log(errorText);
                }

                errorText += "</ul>";
                    console.log(errorText);

                // Insert error list into form
                setUpNotifier("error.png", "Warning", errorText);
            });

        }
        
  function initialize_edit_button()
        {
            $("a.edit-picture").unbind()
                    .bind("ajax:beforeSend", function(evt, xhr, settings) {
                 //alert("ajax:beforeSend");
            })
                    .bind("ajax:success", function(evt, data, status, xhr) {
                // alert("ajax:success");
                edit_picture_dialog(data);
            })
                    .bind('ajax:complete', function(evt, xhr, status) {
                 //alert("ajax:complete");
            })
                    .bind("ajax:error", function(evt, xhr, status, error) {
                //  alert("ajax:error");

                var $form = $(this),
                        errors,
                        errorText;

                try {
                    // Populate errorText with the comment errors
                    console.log(xhr);
                    console.log(status);
                    console.log(error);
                    
                    errors = $.parseJSON(xhr.responseText);
                    console.log(errors);
                    
                } catch (err) {
                    // If the responseText is not valid JSON (like if a 500 exception was thrown), populate errors with a generic error message.
                    errors = {
                        message: "Please reload the page and try again"
                    };
                }
                var errorText;
                // Build an unordered list from the list of errors
                errorText = "<ul>";

                for (error in errors) {
                    console.log(error);
                    console.log(errors[error][0]);
                    errorText += "<li>" + error + ': ' + errors[error][0] + "</li> ";
                    console.log(errorText);
                }

                errorText += "</ul>";
                    console.log(errorText);

                // Insert error list into form
                setUpNotifier("error.png", "Warning", errorText);
            });

        }
        
        
        
        function edit_picture_dialog(data) {

    // alert("ajax:success");
        picture_edit_dialog = createAppDialog(data, "edit-picture", {}, "");

    //initialize_save_button();
    //$('.datepicker').datepicker();
    //tiny_mce_initializer();
    //bind_org_select();
    //bind_membership_select();
    //bind_grade_select();
    //bind_flags_select();

    //bind_grade_all_select();

    //bind_grade_filter_display();
    //bind_membership_filter_display();
    //bind_flags_filter_display();
    //bind_select_ajax("picture_priority");
    //bind_select_ajax("picture_status");



    //current_notice = $("#picture-id").text();
    //set_before_edit(current_notice);
    // tinyMCE.init({"selector":"textarea.tinymce"});
    $(".best_in_place").best_in_place();

    //bind_file_upload_to_upload_form();
    //$("button.ui-dialog-titlebar-close").hide();

    //initialize_add_organization();
    //select_subject_field();
    //initialize_select_all_button();
    //initialize_select_none_button();
    //initilize_filter_buttons();

}
        
        
  function link_to_picture(picture_id, picture_size) {
    $.ajax({
        dataType: "html",
        url: '/pictures/insert',
        cache: false,
        data: {id: picture_id, size:picture_size},
        success: function (data)
        {
            console.log(data);
            $(picture_insert_dialog).dialog("close");
            top.tinymce.activeEditor.insertContent(data);
                        
        },
        error: function (jqXHR, statusText, errorThrown) 
        {
       
         setUpPurrNotifier("Error", "Please select valid image size.");
                        
        }
    });

}
        
     function insert_picture_dialog(data) {
               
      picture_insert_dialog = createAppDialogAdv(data, "insert-picture", {
        completion: function completionCallback() {
        console.log("Complete");
        },
        "Insert": function savedClicked() {
            console.log("Insert Image");
            image_size = $("select#image-size").val();
            picture_id = $("div#insert-picture div#picture-id").text();
            link_to_picture(picture_id, image_size);
            console.log("Size:" + image_size);
            
        },
        "Cancel": function cancelClicked() {
           console.log("Cancel.")
           $(this).dialog("close");
        }
            }, "Insert,Cancel");

}
        
        