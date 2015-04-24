/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

function getRailsTimeStamp()
{
    return $("script").attr("src").split('?')[1]
}
// 
// CSS 3D Utitlities
// 

// A helper function that checks for the
// support of the 3D CSS3 transformations.
function supportsCSS3D() {
    var props = [
        'perspectiveProperty', 'WebkitPerspective', 'MozPerspective'
    ], testDom = document.createElement('a');

    for (var i = 0; i < props.length; i++) {
        if (props[i] in testDom.style) {
            return true;
        }
    }

    return false;
}

// 
// 
// 
// // Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function are_cookies_enabled()
{
    var cookieEnabled = (navigator.cookieEnabled) ? true : false;

    if (typeof navigator.cookieEnabled == "undefined" && !cookieEnabled)
    {
        document.cookie = "testcookie";
        cookieEnabled = (document.cookie.indexOf("testcookie") != -1) ? true : false;
    }

    return (cookieEnabled);
}

//
//
// code to check for mobile device
//
//


function customizeForDevice() {
    var ua = navigator.userAgent;
    var checker = {
        iphone: ua.match(/(iPhone|iPod|iPad)/),
        ipad: ua.match(/(iPad)/),
        blackberry: ua.match(/BlackBerry/),
        android: ua.match(/Android/),
        palm: ua.match(/Palm/)
    };
    if (checker.android) {
        return("mobile:android");
        // $('.android-only').show();
    }
    else if (checker.iPad) {
        return("mobile:ipad");

        //  $('.idevice-only').show();
    }
    else if (checker.iphone) {
        return("mobile:iphone");

        //  $('.idevice-only').show();
    }
    else if (checker.blackberry) {
        return("mobile:blackberry");

        //  $('.berry-only').show();
    }
    else if (checker.palm) {
        return("mobile:palm");

        //  $('.berry-only').show();
    }
    else {
        return(ua);
    }
//  $('.unknown-device').show();
}



function sz(t) {
    a = t.value.split('\n');
    b = 1;
    for (x = 0; x < a.length; x++) {
        if (a[x].length >= t.cols)
            b += Math.floor(a[x].length / t.cols);
    }
    b += a.length;
    if (b > t.rows)
        t.rows = b;
}


//
// javascript loader asycn using ajax
//
//
function require(script) {
    var theUrl = "/assets/" + script;
    var theTimeStamp = getRailsTimeStamp();

    // $("script[src='/javascripts/ie_fixes.js?1361329086']")

    if (!$("script[src^='" + theUrl + "']").length) {
        // alert("loaded");
        $.ajax({
            url: "/site/load_asset",
            data: {path: script},
            dataType: "text",
            async: false, // <-- this is the key
            success: function (data) {

                if (data != "") {
                    var javascriptLink = $("<script>").attr({
                        type: "text/javascript",
                        src: data
                    });
                    $("head").append(javascriptLink);
                }
                // all good...
            },
            error: function () {
                console.warn("Could not load script " + script);
            }
        });
    }
    else
    {
        //      alert("Not Loaded");

    }
}

//
// css loader async using ajax
//
//
function requireCss(cssFile) {
    var theTimeStamp = getRailsTimeStamp();
    // if (cssFile.charAt(0) == "/") {
    var href = "/assets/" + cssFile
    if (!$("link[href^='" + href + "']").length) {
        //alert("loaded");
        $.ajax({
            url: "/site/load_asset",
            data: {path: cssFile},
            dataType: 'text',
            success: function (data) {
                if (data != "") {
                    var cssLink = $("<link>").attr({
                        rel: "stylesheet",
                        type: "text/css",
                        href: data
                    });
                    $("head").append(cssLink);
                }
                //your callback
            },
            fail: function () {
                alert("fail");
            }
        });
    }
    else
    {
        //  alert("Not Loaded");
    }
}
//
//
//  Notifier base code
//
//
function popUpAlertifExists()
{
    var message = $("#alert").text().trim();

    setUpPurrNotifier("Alert", message);

    var message = $("#notice").text().trim();

    setUpPurrNotifier("Alert", message);

}



function setUpPurrNotifier(headline, message)
{
    var notice = ''
            + '<div id="notify-container" style="display:none">'
            + '<div id="notice-body">'
            + '<a class="ui-notify-close ui-notify-cross" href="#">x</a>'
            + '<div class="info-icon" style="float:left;margin:0 10px 0 0; min-height:50px;">'
            //     + '<img src="/assets/interface/info.png" alt="warning">'
            + '</div>'
            + '<h1>#{title}</h1>'
            + '<p>#{text}</p>'
            + '</div>'
            + '</div>';


    if (message.length > 1)
    {
        if ($("#notify-container").length == 0)
        {
            $("body").append($(notice));
        }
        $("#notify-container").notify({
            //  expires: false,
            speed: 1000
        });

        $("#notify-container").notify("create", "notice-body", {
            title: headline,
            text: message
        });
    }
}

function disableSelectOptionsSeperators()
{
    found_options = $("select option");

    found_options.each(function () {
        if ($(this).text() == "-") {
            $(this).prop('disabled', true);
        }
        ;
    });
}

function createPasswordDialog() {

    $('#edit-password-dialog').dialog({
        autoOpen: false,
        width: 706,
        height: 245,
        modal: true
    });
}

function setupCheckboxes(inputElement) {
    $(inputElement).click(function () {
        $(this).closest('form').trigger('submit');
    });

}

function createAppDialog(theContent, dialog_id, call_backs, buttons_to_show_in) {
// completion_callback, save_callback, cancel_callback, submit_callback

    if (typeof call_backs === 'undefined')
        var call_backs = {};
    if (typeof buttons_to_show_in === 'undefined')
        var buttons_to_show_in = "";
    if (typeof dialog_id === 'undefined')
        var dialog_id = "app-dialog";


    buttons_to_show = buttons_to_show_in || "all"
    console.log(buttons_to_show);
    console.log(buttons_to_show_in);
    console.log(buttons_to_show.indexOf("Cancel"));

    if ($("#" + dialog_id).length == 0)
    {
        var dialogContainer = "<div id='" + dialog_id + "' class='cms-ui-dialog'></div>";
        $("body").append($(dialogContainer));
    }
    else
    {
        dialogContainer = $("#" + dialog_id);
    }



// $('#app-dialog').html(theContent);
    theContent = '<input type="hidden" autofocus="autofocus" />' + theContent
    theAppDialog = $('#' + dialog_id).dialog({
        autoOpen: false,
        modal: true,
        close: function (event, ui) {
            if (typeof (call_backs.completion) == "function")
            {
                call_backs.completion();
            }

            // $('#' + dialog_id).html("");
            //  $('#' + dialog_id).dialog("destroy");
            //   alert('closed');
        },
        open: function (event, ui)
        {
            popUpAlertifExists();
        }


    });
    $('#' + dialog_id).html(theContent);
    theHeight = $('#' + dialog_id + ' #dialog-height').text() || "500";
    theWidth = $('#' + dialog_id + ' #dialog-width').text() || "500";
    theTitle = $('#' + dialog_id + ' #dialog-name').text() || "Edit";
    theAppDialog.dialog({
        title: theTitle,
        width: theWidth,
        height: theHeight
    });
    theAppDialog.dialog("open");
    return(theAppDialog)
}

function ui_ajax_select() {

    $("select.ui-ajax-select").bind("change", function () {
        selected_item = $(this).val();
        controller = this.getAttribute("data-path")

        //alert(this.getAttribute("data-id"));


        $.ajax({
            url: controller, // controller + "/update",
            dataType: "json",
            type: "PUT",
            data: "id=" + this.getAttribute("data-id") + "&" + this.getAttribute("name") + "=" + selected_item,
            success: function (data)
            {
                alert(data);
                if (data === undefined || data === null || data === "")
                {
                    //display warning
                }
                else
                {

                }
            }
        });
    });
}


function updateMenu(menu_id)
{
    menu = $('[data-menu-id ="' + menu_id + '"]');
    menu_helper = menu.attr("cms-menu-helper");
    menu_params = menu.attr("data-menu-params")

    if (menu.length > 0) {
        $.ajax({
            url: "/menus/render_menu",
            type: "GET",
            data: {menu_id: menu_id, menu_helper: menu_helper, menu_params: menu_params},
            success: function (data)
            {
                menu.replaceWith(data);
                if (typeof (application_ready_function) == "function")
                {
                application_ready_function();
            }
                // console.log(data);
            }
        });
    }
}

function createButtonList(call_backs,buttons_to_build)
{
    button_list = {};

    $.each(buttons_to_build.split(","), function (index, value) {
        button_list[value] = {
            text: value,
            id: "dialog-" + value + "-button",
            click: function () {
// Do what needs to be done to complete 
                if (typeof (call_backs[value]) == "function")
                {
                    call_backs[value]();
                }
            }
        };

    });
    
    return (button_list);

}

/*
 * 
 *  Sample call of the createAppDialogAdv
createAppDialogAdv("this is test content","test-dialog",{
        completion: function completionCallback() {
        console.log("Complete");
        },
        "Save as Draft": function savedClicked() {
            console.log("Saved")
        },
        "Cancel": function cancelClicked() {
           console.log("Canceled.")
        },
        "Submit": function submitClicked() {
           console.log("Submitted.")
            }}, "Submit,Save as Draft,Cancel")
            
*/

function createAppDialogAdv(theContent, dialog_id, call_backs, buttons_to_show_in) {
// completion_callback, save_callback, cancel_callback, submit_callback


    if ($("#" + dialog_id).length == 0)
    {
        var dialogContainer = "<div id='" + dialog_id + "'></div>";
        $("body").append($(dialogContainer));
    }
    else
    {
        dialogContainer = $("#" + dialog_id);
    }

    button_list = createButtonList(call_backs,buttons_to_show_in);
    
    theContent = '<input type="hidden" autofocus="autofocus" />' + theContent
    theAppDialog = $('#' + dialog_id).dialog({
        autoOpen: false,
        modal: true,
        //       dialogClass: 'no-close',
        buttons: button_list,
        close: function (event, ui) {
            if (typeof (call_backs.completion) == "function")
            {
                call_backs.completion();
            }

            // $('#' + dialog_id).html("");
            //  $('#' + dialog_id).dialog("destroy");
            //   alert('closed');
        },
        open: function (event, ui)
        {
            popUpAlertifExists();
        }


    });
    $('#' + dialog_id).html(theContent);
    theHeight = $('#' + dialog_id + ' #dialog-height').text() || "500";
    theWidth = $('#' + dialog_id + ' #dialog-width').text() || "500";
    theTitle = $('#' + dialog_id + ' #dialog-name').text() || "Edit";
    theAppDialog.dialog({
        title: theTitle,
        width: theWidth,
        height: theHeight
    });
    theAppDialog.dialog("open");
    return(theAppDialog)
}

function findMyEvents(me) {

    if (typeof $._data($(me)[0], 'events') !== "undefined") {
        console.log($(me)[0])
        console.log($._data($(me)[0], 'events'))
        $._data($(me)[0], 'events')
    };
    for (var i = 0; i < $(me).children().length; i++) {
        findMyEvents($(me).children()[i])
    }
}
