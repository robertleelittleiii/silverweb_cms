/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

slider_edit_dialog = "";

function slidereditClickBinding(selector) {
    // selectors .edit-slider-dialog-item, tr.slider-row 

    $(selector).unbind("click").one("click", function () {
        console.log($(this).parent().find('#slider-id').text());
        var slider_id = $(this).parent().find('#slider-id').text();
        var is_iframe = $("application-space").length > 0

        var url = '/sliders/' + slider_id + '/edit?request_type=window&window_type=iframe&as_window=true';

        // $(this).effect("highlight", {color: "#669966"}, 1000);

        $.ajax({
            url: url,
            success: function (data)
            {
                slider_edit_dialog = createAppDialog(data, "edit-slider-dialog-dialog", {}, "");
                slider_edit_dialog.dialog({
                    close: function (event, ui) {
                        current_page_id = $("div#page div#attr-pages div#page-id").text();
                        // show_page(current_page_id);
                        update_content();
                       // tinyMCE.editors[0].destroy();
                        
                        if (typeof top.tinymce.activeEditor != "undefined") {
                            top.tinymce.activeEditor.destroy();
                        }

                        $('#edit-slider-dialog').html("");
                        $('#edit-slider-dialog').dialog("destroy");

                    }
                });

                require("sliders/edit.js");
                sliders_edit_callDocumentReady();
                slider_edit_dialog.dialog('open');


            }
        });




//        if (is_iframe) {
//                        $('iframe#sliders-app-id',window.parent.document).attr("src",url);
//                        slidereditClickBinding(this);
//        }
//        else
//            {
//                window.location = url;
//
//            }

    });
}

