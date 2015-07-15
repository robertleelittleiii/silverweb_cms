/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

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
    requireCss("menus.css");
    require("menus/shared.js");
    if (($.cookie('open_menu_list') == null) || ($.cookie('open_menu_list') == ""))
    {
        $.cookie('open_menu_list', "");
    }
    bindDeleteMenu();
    bindToggleListClick();
    menueditClickBinding("div.targetable");
    makeDraggable();
    initializeCreateMenu();
    bindNewMenuHead();
    $("#alert").click(function () {
        alert(this.getAttribute("data-message"));
        return false;
    });
    $("a.button-link").button();
    handleOpenedMenus();
    setTimeout(function () {
        handleOpenedMenus();
        console.log("delay called")
    }, 1000);
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
                    handleOpenedMenus();
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
        var items_to_set_click = "div.lever-toggle";
    }
    else
    {
        var items_to_set_click = item + " div.lever-toggle";
    }

    $(items_to_set_click).unbind("click").click(function (event) {
        var parentTable = $(this).parent().parent().parent().parent().parent();
        var this_id = $(this).parent().parent().parent().parent().parent().next("ul").attr("id")
        console.log("this ID");
        console.log(this_id);
        console.log(parentTable);
        console.log(this);
        if ($.trim($(parentTable).attr("class")) == "has-sub-menus")
        {
            $(this).parent().parent().parent().parent().parent().next("ul").attr("id")

            $.cookie('open_menu_list', $.unique($.merge($.cookie('open_menu_list').split(","), [this_id])))
            $(this).switchClass("closed", "open");
            // $(this).find("img").attr("src", $(this).find("img").attr("src").replace("closed", "open"))
            $($(this).parent().parent().parent().parent().parent().parent().find("ul")[0]).slideDown();
            $(this).parent().parent().parent().parent().parent().removeClass("has-sub-menus");
            console.log("add sub menus",this, $.cookie("open_menu_list"))
        }
        else
        {
            if ($.trim($($(this).parent().parent().parent().parent().parent().parent().find("ul")[0]).html()).length != 0)
            {
                var theList = $.cookie('open_menu_list').split(",")
                theList.splice(theList.indexOf(this_id), 1)
                $.cookie("open_menu_list", theList)
                $(this).switchClass("open", "closed");
                // $(this).find("img").attr("src", $(this).find("img").attr("src").replace("open", "closed"))
                $($(this).parent().parent().parent().parent().parent().parent().find("ul")[0]).slideUp();
                $(this).parent().parent().parent().parent().parent().addClass("has-sub-menus");
                console.log("remove sub menus",this, $.cookie("open_menu_list"))
            }
        }

        event.stopPropagation();
        return(true);
    });
}
;
function handleOpenedMenus() {
    console.log("handleOpenedMenus => called");
    theList = $.cookie('open_menu_list').split(",");
    $.each(theList, function (key, value) {
        if ($("#" + value).length > 0)
        {
            $("#" + value).slideDown();
            // console.log($($("#" + value).parent().find("div.lever-toggle")[0]));
            $($("#" + value).parent().find("div.lever-toggle")[0]).switchClass("closed", "open");
            // $($("#" + value).parent().find("img")[0]).attr("src", $($("#" + value).parent().find("img")[0]).attr("src").replace("closed", "open"))
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

    $(selection).unbind("click").bind("click", function (e) {
        e.stopPropagation();
        // alert("clicked");
        // console.log($(this).parent().parent().parent().find('#page-id').text());
        var menu_id = $(this).parent().parent().parent().find('#menu-id').text();
        console.log("the MenuID=> " + menu_id);
        deleteMenu(menu_id, this);
        return false;
    });
}

function deleteMenu(menu_id, menuItem)
{
    var answer = confirm('Are you sure you want to delete this?')
    if (answer) {
        $.ajax({
            url: '/menus/delete_ajax?id=' + menu_id,
            success: function (data)
            {
                setUpPurrNotifier("Notice", "Item Successfully Deleted.");
                console.log($(menuItem).parent().parent().parent().parent().parent().parent());
                thisItem = $(menuItem).parent().parent().parent().parent().parent().parent();
                $(thisItem).fadeOut();
                $(thisItem).find("ul").fadeOut();
                //$(thisItem).prev("div").hide();
            }
        });
    }
}


//
//function bindDeleteMenu(selection) {
//
//    if (typeof selection === 'undefined')
//    {
//        selection = ".delete_menu";
//    }
//    else
//    {
//        var selection = selection + " .delete_menu";
//    }
//
//    $(selection).unbind('ajax:success').bind('ajax:success', function () {
//        $(this).parent().parent().parent().parent().parent().fadeOut();
//        $(this).parent().parent().parent().parent().parent().parent().find("ul").fadeOut();
//        $(this).parent().parent().parent().parent().parent().prev("div").hide();
//
//        // $(this).closest('table').fadeOut();
//        // alert("deleted");
//    })
//
//}





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
            // menueditClickBinding(this_item);
            menueditClickBinding();
            makeDraggable(this_item);
            initializeCreateMenu(this_item);
            handleOpenedMenus();
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
            bindDeleteMenu();
            bindToggleListClick();
            menueditClickBinding();
            makeDraggable();
            initializeCreateMenu();
            handleOpenedMenus();
        }
    });
}


function initializeCreateMenu(selection) {

    if (typeof selection === 'undefined')
    {
        selection = "img.create-menu";
    }
    else
    {
        var selection = selection + " img.create-menu";
    }


    $(selection).unbind("click").bind("click", function (e) {
        e.stopPropagation();
        // alert("clicked");
        // console.log($(this).parent().parent().parent().find('#page-id').text());
        console.log("in click on add menu")
        console.log(this);
        createMenu(this);
        return false;
    });
}


function createMenu(menuItem)
{
    parent_menu_id = $(menuItem).parent().parent().parent().parent().parent().parent().find("div#parent-id").html();
    //console.log($("ul#sortable_" + parent_menu_id).html("test..."))
    console.log($(menuItem).parent().parent());

    $.ajax({
        url: '/menus/create_empty_record?parent_id=' + parent_menu_id + "&typeofrecord=Child",
        success: function (data)
        {
            console.log(data);
            setUpPurrNotifier("Notice", "Item Successfully Created.");
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
            handleOpenedMenus();
            updateMenuItem(parent_menu_id)
        }
    });

}





//function initializeCreateMenu(selection) {
//
//    if (typeof selection === 'undefined')
//    {
//        selection = "a.create-menu";
//    }
//    else
//    {
//        var selection = selection + " a.create-menu";
//    }
//
//
//    $(selection).unbind("ajax:success").bind("ajax:success", function (event, data, status, xhr) {
//        event.stopPropagation();
//        parent_menu_id = $(this).parent().parent().parent().parent().parent().parent().find("div#parent-id").html();
//        console.log(data);
//        //console.log($("ul#sortable_" + parent_menu_id).html("test..."))
//        $("ul#sortable_" + parent_menu_id).html(data);
//        $($(this).parent().parent().parent().parent().parent().parent().find("ul")[0]).slideDown();
//        // console.log(this);
//        // console.log(parent_menu_id);//.find("div#parent-id")
//        // alert("this is a test");
//        // console.log(event);
//        //handleOpenedMenus();
//        bindDeleteMenu();
//        bindToggleListClick();
//        menueditClickBinding();
//        makeDraggable();
//        initializeCreateMenu();
//        handleOpenedMenus();
//    });
//}


function bindNewMenuHead() {

    $('a#new-menu-head').unbind().bind('ajax:beforeSend', function (e, xhr, settings) {
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("body").css("cursor", "progress");
    }).bind('ajax:success', function (xhr, data, status) {
        $("body").css("cursor", "default");
        // updateMenuItem(0);
        $("div#menu-item-list").html(data);
        menus_index_callDocumentReady();
        setUpPurrNotifier("Notice", "New Menu Head Created!'");
    }).bind('ajax:error', function (evt, xhr, status, error) {
        setUpPurrNotifier("Error", "Menu Creation Failed!'");
    });
}