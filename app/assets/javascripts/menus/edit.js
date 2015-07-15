/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

var menus_edit_callDocumentReady_called = false;

$(document).ready(function () {
    if (!menus_edit_callDocumentReady_called)
    {
        menus_edit_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        }
        else
        {
            menus_edit_callDocumentReady();
        }
    }
});


function menus_edit_callDocumentReady() {
    //alert("called.");
    bindMenuRawhtml();
    bindMenuMType();
    bind_file_upload_to_upload_form();
    ui_ajax_select();
    bindDeleteImage();
        $(".best_in_place").best_in_place();
    requireCss("image_libraries/image_list.css");
};


function bindMenuRawhtml() {

    $("#menu_rawhtml").bind("change", function () {
        selected_item = $("#menu_rawhtml option:selected");
        //alert(this.getAttribute("data-id"));


        $.ajax({
            url: "/menus/ajax_load_partial",
            dataType: "html",
            type: "POST",
            data: "id=" + this.getAttribute("data-id") + "&partial_type=" + (selected_item.text().replace(" ", "_").toLowerCase()),
            success: function (data)
            {
                //alert(data);
                if (data === undefined || data === null || data === "")
                {
                    //display warning
                }
                else
                {
                    $("#action-step").html(data);
                    $(".best_in_place").best_in_place();
                    ui_ajax_select();
                    //initTinyMCE();
                }
            }
        });
    });
}



function bindMenuMType() {
    $("#menu_m_type").bind("change", function () {
        selected_item = $("#menu_m_type option:selected");
        //alert(this.getAttribute("data-id"));


        $.ajax({
            url: "/menus/ajax_load_partial",
            dataType: "html",
            type: "POST",
            data: "id=" + this.getAttribute("data-id") + "&partial_type=" + selected_item.text(),
            success: function (data)
            {
                //alert(data);
                if (data === undefined || data === null || data === "")
                {
                    //display warning
                }
                else
                {
                    $("#menu-options").html(data);
                    $(".best_in_place").best_in_place();
                    //initTinyMCE();
                    bindMenuRawhtml();
                    ui_ajax_select();
                }
            }
        });

    });
}


function mysave() {
    console.log("trigger save");
    tinymce.triggerSave();
    // $("#page-body-save").closest("form").trigger("submit");
    $("#menu_rawhtml").parent().parent().closest("form").trigger("submit");

    []
}

function bind_file_upload_to_upload_form()
{
    $("form.upload-form").fileupload({
        dataType: "json",
        add: function (e, data) {
            file = data.files[0];
            data.context = $(tmpl("template-upload", file));
            // $("div.progress").progressbar();
            $('#pictures').append(data.context);
            var jqXHR = data.submit()
                    .success(function (result, statusText, jqXHR) {

                        // console.log("------ - fileupload: Success - -------");
                        // console.log(result);
                        // console.log(statusText);
                        // console.log(jqXHR);

                        // console.log(JSON.stringify(jqXHR.responseJSON["attachment"]));

                        // console.log(typeof(jqXHR.responseText));
// specifically for IE8. 
                        if (typeof (jqXHR.responseText) == "undefined") {
                            setUpPurrNotifier("info.png", "Notice", jqXHR.responseJSON["attachment"][0]);
                            data.context.remove();
                        }
                        else
                        {
                            render_pictures(result.id);



                        }

                    })
                    .error(function (jqXHR, statusText, errorThrown) {
                        console.log("------ - fileupload: Error - -------");
                        console.log(jqXHR.status);
                        console.log(statusText);
                        console.log(errorThrown);
                        console.log(jqXHR.responseText);
                        if (jqXHR.status == "200")
                        {
                            render_pictures(result.id);
                        }
                        else
                        {
                            var obj = jQuery.parseJSON(jqXHR.responseText);
                            // console.log(typeof obj["attachment"][0])
                            setUpPurrNotifier("info.png", "Notice", obj["attachment"][0]);
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
}


function bind_download_to_files()
{
    $("div.file-item div#logo-links").unbind("click");
    $("div.file-item div#logo-links").bind("click",
            function () {
                var href = $($(this)[0]).find('a').attr('href');
                window.location.href = href
            });
}

function render_pictures(picture_id) {
    $.ajax({
        dataType: "html",
        url: '/pictures/render_picture',
        cache: false,
        data: "id=" + picture_id,
        success: function (data)
        {
            $("div#images").html(data).hide().fadeIn();

            max_images = $('#max-images').text();

            if (max_images.length > 0)
            {
                total_images = $("div.file-list-item").size();
                if (total_images >= max_images) {
                    $("div#imagebutton").fadeOut();
                }

            }
            bindDeleteImage();
            bind_file_upload_to_upload_form();


        }
    });

}

function bindDeleteImage() {
    $('a.picture-delete').unbind().bind('ajax:beforeSend', function () {
        // alert("ajax:before");  
    }).bind('ajax:success', function () {
        console.log($(this).parent().parent());
        $(this).parent().parent().remove();
        $("div#imagebutton").show();
        //  alert("ajax:success");  
    }).bind('ajax:failure', function () {
        //    alert("ajax:failure");    
    }).bind('ajax:complete', function () {
        //   alert("ajax:complete"); 
    });

}
$(document).off('focusin').on('focusin', function (e) {
    if ($(event.target).closest(".mce-window").length) {
        e.stopImmediatePropagation();
        console.log("worked!");
    }
});