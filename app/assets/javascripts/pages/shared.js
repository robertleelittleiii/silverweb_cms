/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

page_edit_dialog = "";

function pageeditClickBinding(selector) {
    // selectors .edit-page-item, tr.page-row 

    $(selector).unbind("click").one("click", function (event) {
        event.stopPropagation();
        console.log($(this).find('#page-id').text());
        var page_id = $(this).find('#page-id').text();
        var is_iframe = $("application-space").length > 0

        var url = '/pages/' + page_id + '/edit?request_type=window&window_type=iframe&as_window=true';

        // $(this).effect("highlight", {color: "#669966"}, 1000);

        $.ajax({
            url: url,
            success: function (data)
            {
                page_edit_dialog = createAppDialog(data, "edit-page", {}, "");
                page_edit_dialog.dialog({
                    close: function (event, ui) {
                        if ($("table#page-table").length > 0)
                            pageTableAjax.draw();

                        if ($("div#edit-page").length > 0)
                        {
                            current_page_id = $("div#page div#attr-pages div#page-id").text();
                            if (page_id === current_page_id)
                            {
                                update_content();
                                //show_page(page_id);
                            }
                        }
                        pageeditClickBinding("div#edit-pages");

                        //tinyMCE.editors[0].destroy();
                        top.tinymce.activeEditor.destroy();
                        $('#edit-page').html("");
                        $('#edit-page').dialog("destroy");


                    }
                });

                require("pages/edit.js");
                requireCss("pages/edit.css");
                requireCss("pages.css");

                pages_edit_callDocumentReady();
                page_edit_dialog.dialog('open');


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

