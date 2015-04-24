/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

var global_editor_hold = "";
var tinyMCE_editor_page = "";
var pages_edit_callDocumentReady_called = false;
var slider_edit_dialog = "";
var result_test = "";

$(document).ready(function () {
    if (!pages_edit_callDocumentReady_called)
    {
        pages_edit_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        }
        else
        {
            pages_edit_callDocumentReady();
        }
    }
});


function pages_edit_callDocumentReady() {
    $("#page-tabs").tabs();
    loadCustomCSS();
    activate_scroller_sort();
    set_up_delete_slider_callback();
    set_up_add_slider_callback();
    setupCheckboxes(".security-check");
    $(".best_in_place").best_in_place();
    ui_ajax_select();
    $("a.button-link").button();
    $('#page_body_save').bind("click", function () {
        // alert("clicked");
        $(this).closest("form").trigger("submit");
        return true;
    });
    sliderEditClickBinding("ul#sliders li");
    tinyMCE_editor_page = tinyMCE.init(tinymce_config);
    //tinyMCE.get("page_body").editor.on('ExecCommand', function(e) {
    //        console.log('ExecCommand event', e);
    //   })

    // setTimeout(function(){bind_file_paste_to_upload_form();},2000); 
bind_versions_links();
}


function activate_scroller_sort() {

    $('#sliders').sortable({
        axis: 'y',
        dropOnEmpty: false,
        handle: '.slider-drag',
        cursor: 'crosshair',
        items: 'li',
        opacity: 0.4,
        scroll: true,
        update: function () {
            page_id = $("div#edit-page #page-id").html().trim();

            $.ajax({
                type: 'post',
                data: $('#sliders').sortable('serialize') + "&page_id=" + page_id,
                dataType: 'script',
                complete: function (request) {
                    $('#sliders').effect('highlight');
                },
                url: '/sliders/sort'
            })
        }
    });
}

function updateSliderList() {

    page_id = $("div#edit-page #page-id").html().trim();
    $.ajax({
        type: 'GET',
        data: 'page_id=' + page_id,
        dataType: 'html',
        success: function (data) {
            $('ul#sliders').html(data);
            activate_scroller_sort();
            set_up_delete_slider_callback();
            $('iframe.preview').attr("src", $('iframe.preview').attr("src"));
            sliderEditClickBinding("ul#sliders li");
        },
        url: '/pages/get_sliders_list'
    });

}
function set_up_add_slider_callback() {

    $("#add-slider")
            .bind("ajax:success", function (event, data, status, xhr) {
                updateSliderList();
            });
}

function set_up_delete_slider_callback() {

    $(".delete_slider")
            .bind('ajax:beforeSend', function (e, xhr, settings) {
                e.stopPropagation();
            }).bind("ajax:success", function (event, data, status, xhr) {
        updateSliderList();
    });

}

function loadCustomCSS() {

    var custom_css = $("#best_in_place_page_template_name").text();
    requireCss("site/show_page-" + custom_css + ".css");
}

// triggered when the save button is clicked in tinemce.

function mysave() {
    console.log("trigger save");
    tinymce.triggerSave();
    // $("#page-body-save").closest("form").trigger("submit");
    $("#page_body").parent().parent().closest("form").trigger("submit");

}

function ajaxSave()
{

    tinyMCE.triggerSave();

    $("#page_body_save").closest("form").trigger("submit");


}

function BestInPlaceCallBack(input) {

    $('iframe.preview').attr("src", $('iframe.preview').attr("src"));
    loadCustomCSS();
}


function tinyMcePostInit(inst) {
    pages_bind_file_paste_to_upload_form();
}

function pages_bind_file_paste_to_upload_form()
{
    $("form#picture-paste-page").fileupload({
        dataType: "json",
        pasteZone: $("iframe#page_body_ifr").contents().find("body"),
        add: function (e, data) {
            file = data.files[0];
            data.context = $(tmpl("template-upload", file));
            // $("div.progress").progressbar();
            // $('#pictures').append(data.context);
            var jqXHR = data.submit()
                    .success(function (result, statusText, jqXHR) {

                        //   console.log("------ - fileupload: Success - -------");
                        //  console.log(result);
                        //   console.log(statusText);
                        //   console.log(jqXHR);

                        //  console.log(JSON.stringify(jqXHR.responseJSON["attachment"]));

                        //  console.log(typeof (jqXHR.responseText));


// specifically for IE8. 
                        if (typeof (jqXHR.responseText) == "undefined") {
                            top.tinymce.activeEditor.undoManager.undo();
                            setUpPurrNotifier("info.png", "Notice", jqXHR.responseJSON["attachment"][0]);
                            data.context.remove();
                        }
                        else
                        {
                            top.tinymce.activeEditor.undoManager.undo();
                            //  console.log(result.image.url)
                            image_tag = "<img src='" + result.image.url + "'/>"
                            top.tinymce.activeEditor.insertContent(image_tag);
                            console.log("success");
                            //  render_pictures();
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
                        // console.log("------ - fileupload: Complete - -------");
                        // console.log(result);
                        // console.log(textStatus);
                        // console.log(jqXHR);
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
            // console.log(e);
            // console.log(data);
            //data.context.text('');
        }
    }).bind('fileuploaddone', function (e, data) {
        // console.log(e);
        // console.log(data);
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

function bind_download_to_files()
{
    $("div.file-item div#logo-links").unbind("click");
    $("div.file-item div#logo-links").bind("click",
            function () {
                var href = $($(this)[0]).find('a').attr('href');
                window.location.href = href
            });
}


function sliderEditClickBinding(selector) {
    // selectors .edit-page-item, tr.page-row 

    $(selector).unbind("click").one("click", function (e) {
        if (e.target.id === "delete-button")
            return;
        console.log(e.target.id);
        console.log($(this).find('#slider-id').text());
        var slider_id = $(this).find('#slider-id').text();
        var is_iframe = $("application-space").length > 0

        var url = '/sliders/' + slider_id + '/edit?request_type=window&window_type=iframe&as_window=true';

        $(this).effect("highlight", {color: "#669966"}, 1000);

        $.ajax({
            url: url,
            success: function (data)
            {
                $("form#picture-paste-page").fileupload('destroy');
                tinyMCE.EditorManager.execCommand('mceRemoveEditor', true, "page_body");

                slider_edit_dialog = createAppDialog(data, "edit-slider-dialog", {}, "");
                slider_edit_dialog.dialog({
                    close: function (event, ui) {
                        updateSliderList();
                        $('#edit-slider-dialog').html("");
                        $('#edit-slider-dialog').dialog("destroy");
                        tinymce.EditorManager.execCommand('mceAddEditor', true, "page_body");
                        pages_bind_file_paste_to_upload_form();
                    }
                });
                slider_edit_dialog.dialog('open');

                require("sliders/edit.js");
                requireCss("sliders.css");

                sliders_edit_callDocumentReady();
            }
        });




//        if (is_iframe) {
//                        $('iframe#pages-app-id',window.parent.document).attr("src",url);
//                        pageeditClickBinding(this);
//        }
//        else
//            {
//                window.location = url;
//
//            }

    });
}

function bind_versions_links() {
    $('a.version-info').unbind().bind('ajax:beforeSend', function (e, xhr, settings) {
        $("body").css("cursor", "progress");
    }).bind('ajax:success', function (xhr, data, status) {
        $("body").css("cursor", "default");
        console.log(xhr);
        console.log(data);
        result_test = data;
        console.log(status);
        
        $("div#best_in_place_page_title").text(data["title"]);
        tinyMCE.activeEditor.setContent(data["body"]);
        console.log(this);
        console.log($(this).text());
        $("a.version-info").each(function(item) {
            $(this).removeClass('selected');
        });
        $(this).addClass('selected');
        $("span#version-number").text($(this).text());
        
        setUpPurrNotifier("Notice", "Version Loaded!'");
    }).bind('ajax:error', function (evt, xhr, status, error) {
        setUpPurrNotifier("Error", "Version load failed!'");
    });

}

$(document).on('focusin', function(e) {
    if ($(event.target).closest(".mce-window").length) {
        e.stopImmediatePropagation();
    }
});