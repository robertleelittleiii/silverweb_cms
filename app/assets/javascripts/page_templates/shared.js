/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

page_edit_dialog = "";

function pagetemplateeditClickBinding(selector) {
    // selectors .edit-page-item, tr.page-template-row 

    $(selector).unbind("click").one("click", function () {
        console.log($(this).find('#page-template-id').text());
        var page_template_id = $(this).find('#page-template-id').text();
        var is_iframe = $("application-space").length > 0

        var url = '/page_templates/' + page_template_id + '/edit?request_type=window&window_type=iframe&as_window=true';

        // $(this).effect("highlight", {color: "#669966"}, 1000);

        $.ajax({
            url: url,
            success: function (data)
            {
                page_edit_dialog = createAppDialog(data, "edit-page-template", {}, "");
                page_edit_dialog.dialog({
                    close: function (event, ui) {
                        if ($("table#page-template-table").length > 0)
                            pagetemplateTableAjax.fnDraw();
                        
                        if ($("div#edit-page-template").length > 0)
                        {
                         current_page_template_id = $("div#page div#attr-page_templates div#page-template-id").text();
                            if (page_template_id === current_page_template_id)
                            {
                                show_page(page_template_id);
                            }
                        }
                        tinyMCE.editors[0].destroy();
                        $('#edit-page-template').html("");
                        $('#edit-page-template').dialog("destroy");

                    }
                });
                
                require("page_templates/edit.js");
                page_templates_edit_callDocumentReady();
                page_edit_dialog.dialog('open');


            }
        });




//        if (is_iframe) {
//                        $('iframe#page_templates-app-id',window.parent.document).attr("src",url);
//                        pagetemplateeditClickBinding(this);
//        }
//        else
//            {
//                window.location = url;
//
//            }

    });
}

