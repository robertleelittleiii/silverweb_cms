/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */


var menu_edit_dialog = "";

function menueditClickBinding(selector, table_val) {
    // selectors .edit-menu-item, tr.menu-row 
    if (typeof selector === 'undefined') {
        if (typeof selector === 'undefined')
        {
            selector = "td.menu-item";
        }
        else
        {
            var selector = selector + " td.menu-item";
        }
    }

    console.log(selector);

    $(selector).unbind("click").one("click", function (event) {
        event.stopPropagation();
        console.log(this);
        console.log($(this).find('#menu-id').first().text());
        var menu_id = $(this).find('#menu-id').first().text();

        var is_iframe = $("application-space").length > 0
        var url = '/menus/' + menu_id + '/edit?request_type=window&window_type=iframe&as_window=true';

        $(this).effect("highlight", {color: "white"}, 1000);

        $.ajax({
            url: url,
            success: function (data)
            {
                menu_edit_dialog = createAppDialog(data, "edit-menu-dialog", {}, "");
                var top_parent = $('#top-parent').text();
                menu_edit_dialog.dialog('open');
                menu_edit_dialog.dialog({
                    close: function (event, ui) {
                        //menuTableAjax.fnDraw();
                       
                        if (typeof updateMenuItem != 'undefined')
                        {
                         //   console.log("updateMenuItem")
                            updateMenuItem(menu_id);
                        }
                        if (typeof updateMenu != 'undefined')
                        {
                        //     console.log("updateMenu")

                            updateMenu(top_parent);
                        }
                        if ($("div.edit-menu").length > 0) {
                            menueditClickBinding("div.edit-menu", true);
                        }
                        
                        menueditClickBinding();
//                        this_item = "div#field_" + menu_id

//                        bindDeleteMenu(this_item);
//                        bindToggleListClick(this_item);
//                        menueditClickBinding(this_item);
//                        makeDraggable(this_item);
//                        initializeCreateMenu(this_item);
                        // updateMenuList();
                        //tinyMCE.editors[0].destroy();
                        top.tinymce.activeEditor.destroy();
                        $('#edit-menu-dialog').html("");
                        $('#edit-menu-dialog').dialog("destroy");
                       

                    }
                });
                require("menus/edit.js");
                menus_edit_callDocumentReady();
                $("div#edit-menu .best_in_place").best_in_place();

            }
        });



    });
}

