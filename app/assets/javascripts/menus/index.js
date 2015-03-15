/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

var menu_edit_dialog = ""
var menus_index_callDocumentReady_called = false;

$(document).ready(function () {
    if (!menus_index_callDocumentReady_called)
    {
        menus_index_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        }
        else
        {
            menus_index_callDocumentReady()
        }
    }

});


function menus_index_callDocumentReady() {

    if (($.cookie('open_menu_list') == null) || ($.cookie('open_menu_list') == ""))
    {
        $.cookie('open_menu_list', "null");
    }
    handleOpenedMenus();
    bindDeleteMenu();
    bindToggleListClick();
    menueditClickBinding();
    makeDraggable();
    initializeCreateMenu();

    $("#alert").click(function () {
        alert(this.getAttribute("data-message"));
        return false;
    });
        $("a.button-link").button();

}

function addHasChildren(field_table)
{
    console.log(field_table);
    $($(field_table).find("table")[0]).removeClass("has-sub-menus")
    $($($(field_table).find("table")[0]).parent().find("ul")[0]).slideDown();
    $($(field_table).find("img")[0]).attr("src", $(field_table).find("img").attr("src").replace("closed", "open"));
    $($(field_table).find("img")[0]).attr("src", $(field_table).find("img").attr("src").replace("disabled", "open"));

    $.cookie('open_menu_list', $.unique($.merge($.cookie('open_menu_list').split(","), [$("#field_1").find("ul").first().attr("id")])));

}

function makeDraggable(selection)
{
    if (typeof selection === 'undefined')
    {
        selection = ".draggable_menu_item";
    }
    else
    {
        var selection = selection + " .draggable_menu_item";
    }


    $(selection).sortable({
        axis: 'y',
        dropOnEmpty: false,
        handle: '.menu-drag',
        cursor: 'crosshair',
        items: 'div.targetable',
        opacity: 0.4,
        scroll: true,
        update: function (event, ui) {
            $.ajax({
                type: 'post',
                data: $(this.getAttribute("data-id")).sortable('serialize'),
                dataType: 'script',
                complete: function (request) {
                    // console.log("menu-id" + $(this).parent().find("div#menu-id").text());
                    parent_menu_id = ui.item.parent().parent().find("#parent-id").text();
                    updateMenu(parent_menu_id);
                    
                    //  $('.draggable_menu_item').effect('highlight');
                },
                url: '/menus/update_order'
            })
        }
    });

}

function bindToggleListClick(item) {

    if (typeof item === 'undefined')
    {
        var items_to_set_click = "a.lever-toggle";
    }
    else
    {
        var items_to_set_click = item + " a.lever-toggle";
    }

    $(items_to_set_click).unbind("click").click(function () {
        var parentTable = $(this).parent().parent().parent().parent().parent();
        var this_id = $(this).parent().parent().parent().parent().parent().next("ul").attr("id")
        console.log("this ID")
        console.log(this_id)
        
        if ($.trim($(parentTable).attr("class")) == "has-sub-menus")
        {
            $(this).parent().parent().parent().parent().parent().next("ul").attr("id")

            $.cookie('open_menu_list', $.unique($.merge($.cookie('open_menu_list').split(","), [this_id])))
            $(this).find("img").attr("src", $(this).find("img").attr("src").replace("closed", "open"))
            $($(this).parent().parent().parent().parent().parent().parent().find("ul")[0]).slideDown();
            $(this).parent().parent().parent().parent().parent().removeClass("has-sub-menus");
        }
        else
        {
            if ($.trim($($(this).parent().parent().parent().parent().parent().parent().find("ul")[0]).html()).length != 0)
            {
                var theList = $.cookie('open_menu_list').split(",")
                theList.splice(theList.indexOf(this_id), 1)
                $.cookie("open_menu_list", theList)

                $(this).find("img").attr("src", $(this).find("img").attr("src").replace("open", "closed"))
                $($(this).parent().parent().parent().parent().parent().parent().find("ul")[0]).slideUp();
                $(this).parent().parent().parent().parent().parent().addClass("has-sub-menus");
            }
        }
        return(false);
    });
}
;

function handleOpenedMenus() {
    theList = $.cookie('open_menu_list').split(",");
    $.each(theList, function (key, value) {
        if ($("#" + value).length > 0)
        {
            $("#" + value).slideDown();
            $($("#" + value).parent().find("img")[0]).attr("src", $($("#" + value).parent().find("img")[0]).attr("src").replace("closed", "open"))
            $($("#" + value).parent().find("table")[0]).removeClass("has-sub-menus");
        }
        //alert(key + ': ' + value); 
    });
}
;

function bindDeleteMenu(selection) {

    if (typeof selection === 'undefined')
    {
        selection = ".delete_menu";
    }
    else
    {
        var selection = selection + " .delete_menu";
    }

    $(selection).unbind('ajax:success').bind('ajax:success', function () {
        $(this).parent().parent().parent().parent().parent().fadeOut();
        $(this).parent().parent().parent().parent().parent().parent().find("ul").fadeOut();
        $(this).parent().parent().parent().parent().parent().prev("div").hide();

        // $(this).closest('table').fadeOut();
        // alert("deleted");
    })

}


function menueditClickBinding(selector) {
    // selectors .edit-menu-item, tr.menu-row 
    if (typeof selector === 'undefined')
    {
        selector = "td.menu-item";
    }
    else
    {
        var selector = selector + " td.menu-item";
    }


    $(selector).unbind("click").one("click", function () {
        console.log($(this).find('#menu-id').text());
        var menu_id = $(this).find('#menu-id').text();
        var is_iframe = $("application-space").length > 0
        var url = '/menus/' + menu_id + '/edit?request_type=window&window_type=iframe&as_window=true';

        $(this).effect("highlight", {color: "white"}, 1000);

        $.ajax({
            url: url,
            success: function (data)
            {
                menu_edit_dialog = createAppDialog(data, "edit-menu", {}, "");
                var top_parent = $('#top-parent').text();
                menu_edit_dialog.dialog('open');
                menu_edit_dialog.dialog({
                    close: function (event, ui) {
                        //menuTableAjax.fnDraw();
                        $('#edit-menu').html("");
                        $('#edit-menu').dialog("destroy");

                        updateMenuItem(menu_id);
                        updateMenu(top_parent);

//                        this_item = "div#field_" + menu_id

//                        bindDeleteMenu(this_item);
//                        bindToggleListClick(this_item);
//                        menueditClickBinding(this_item);
//                        makeDraggable(this_item);
//                        initializeCreateMenu(this_item);
                        // updateMenuList();

                    }
                });
                require("menus/edit.js");
                menus_edit_callDocumentReady();
                $("div#edit-menu .best_in_place").best_in_place()
            }
        });



    });
}


function updateMenuItem(menu_id) {

    $.ajax({
        url: "/menus/render_menu_list",
        type: "GET",
        data: "menu_id=" + menu_id,
        success: function (data)
        {
            $("div#field_" + menu_id).html(data);
            this_item = "div#field_" + menu_id

            bindDeleteMenu(this_item);
            bindToggleListClick(this_item);
            menueditClickBinding(this_item);
            makeDraggable(this_item);
            initializeCreateMenu(this_item);

            // console.log($(data).find("div"));

            //            $("div#menu-item-list").html(data);
            //            handleOpenedMenus();
            //            bindDeleteMenu();
            //            bindToggleListClick();
            //            menueditClickBinding("td.menu-item");
            //            makeDraggable();
            //            initializeCreateMenu();
        }
    });

}
function updateMenuList() {

    $.ajax({
        url: "/menus/update_menu_list",
        type: "GET",
        success: function (data)
        {
            $("div#menu-item-list").html(data);
            handleOpenedMenus();
            bindDeleteMenu();
            bindToggleListClick();
            menueditClickBinding();
            makeDraggable();
            initializeCreateMenu();
        }
    });
}

function initializeCreateMenu(selection) {

    if (typeof selection === 'undefined')
    {
        selection = "a.create-menu";
    }
    else
    {
        var selection = selection + " a.create-menu";
    }


    $(selection)
            .unbind("ajax:success").bind("ajax:success", function (event, data, status, xhr) {
        parent_menu_id = $(this).parent().parent().parent().parent().parent().parent().find("div#parent-id").html();
        console.log(data);
        //console.log($("ul#sortable_" + parent_menu_id).html("test..."))
        $("ul#sortable_" + parent_menu_id).html(data);
        $($(this).parent().parent().parent().parent().parent().parent().find("ul")[0]).slideDown();
        // console.log(this);
        // console.log(parent_menu_id);//.find("div#parent-id")
        // alert("this is a test");
        // console.log(event);
        //handleOpenedMenus();
        bindDeleteMenu();
        bindToggleListClick();
        menueditClickBinding();
        makeDraggable();
        initializeCreateMenu();
    });
}