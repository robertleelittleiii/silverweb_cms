/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

function getRailsTimeStamp()
{
    // return $("script").attr("src").split('?')[1]

    // return $("script").first().attr("src").split('-')[1].split(".")[0]

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
    } else if (checker.iPad) {
        return("mobile:ipad");

        //  $('.idevice-only').show();
    } else if (checker.iphone) {
        return("mobile:iphone");

        //  $('.idevice-only').show();
    } else if (checker.blackberry) {
        return("mobile:blackberry");

        //  $('.berry-only').show();
    } else if (checker.palm) {
        return("mobile:palm");

        //  $('.berry-only').show();
    } else {
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
    // var theTimeStamp = getRailsTimeStamp();

    // $("script[src='/javascripts/ie_fixes.js?1361329086']")

    //  if (!$("script[src^='" + theUrl + "']").length) {
    // alert("loaded");
    //

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

                // handle frame based cloud system
                if ($('iframe.iframe-application').length) {
                    if (!$('iframe.iframe-application').contents().find('head script[src$="' + data + '"]').length) {
                        $("head").append(javascriptLink);
                    }

                } else if (!$('script[src="' + data + '"]').length) {
                    $("head").append(javascriptLink);
                }
            }
            // all good...
        },
        fail: function () {
            console.warn("Could not load script " + script);
        }
    });
}

//
// css loader async using ajax
//
//
function requireCss(cssFile) {
    // var theTimeStamp = getRailsTimeStamp();
    // var theTimeStamp = getRailsTimeStamp();
    // if (cssFile.charAt(0) == "/") {
    var href = "/assets/" + cssFile;
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
                // $('link[href$="'+ data +'"]').length
                if ($('iframe.iframe-application').length) {
                    if (!$('iframe.iframe-application').contents().find('head link[href$="' + data + '"]').length) {
                        $("head").append(cssLink);
                    }
                } else if (!$('link[href$="' + data + '"]').length) {
                    $("head").append(cssLink);
                }
            }
            //your callback
        },
        fail: function () {
            console.warn("Could not load script " + script);
        }
    });

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

    $("#alert").text("");

    var message = $("#notice").text().trim();

    setUpPurrNotifier("Alert", message);

    $("#notice").text("");

}

function setUpNotifier(icon, headline, message)
{
    var notice = ''
            + '<div id="notify-container" style="display:none">'
            + '<div id="notice-body">'
            + '<a class="ui-notify-close ui-notify-cross" href="#">x</a>'
            + '<div style="float:left;margin:0 10px 0 0; min-height:50px;">'
            + '<div class="info-icon" style="float:left;margin:0 10px 0 0; min-height:50px;">'
//            + '<img src="/assets/interface/#{icon}" height="38" alt="warning">'
            + '</div>'
            + '<h1>#{title}</h1>'
            + '<p>#{text}</p>'
            + '</div>'
            + '</div>';
    if (typeof (message) != "undefined" && message.length > 1)
    {
        if ($("#notify-container").length == 0)
        {
            $("body").append($(notice));
        }
        $("#notify-container").notify({
            //  expires: false,
            //  speed: 1000
        });
        $("#notify-container").notify("create", "notice-body", {
            title: headline,
            text: message,
            icon: icon
        });
    }
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

// callbacks example:
//
//    { completion: function completionCallback() {
//    
//        },
//      save: function saveCallback() {
//      
//      }
//      
//
//    
    if (typeof call_backs === 'undefined')
        var call_backs = {};
    if (typeof buttons_to_show_in === 'undefined')
        var buttons_to_show_in = "";
    if (typeof dialog_id === 'undefined')
        var dialog_id = "app-dialog";


    buttons_to_show = buttons_to_show_in || "all"
    //   console.log(buttons_to_show);
    //   console.log(buttons_to_show_in);
    //   console.log(buttons_to_show.indexOf("Cancel"));

    if ($("#" + dialog_id).length == 0)
    {
        var dialogContainer = "<div id='" + dialog_id + "' class='cms-ui-dialog'></div>";
        $("body").append($(dialogContainer));
    } else
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

            $('#' + dialog_id).html("");
            $('#' + dialog_id).dialog("destroy");
            $('#' + dialog_id).remove();


            //    alert('closed');
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

function ui_ajax_select(success_callback) {

    $("select.ui-ajax-select").off("change").on("change", function () {
        selected_item = $(this).val();
        controller = this.getAttribute("data-path")
        that = this
        //alert(this.getAttribute("data-id"));


        $.ajax({
            url: controller, // controller + "/update",
            dataType: "json",
            type: "PUT",
            data: "id=" + this.getAttribute("data-id") + "&" + this.getAttribute("name") + "=" + selected_item,
        }).success(function (data, textStatus, jqXHR)
        {
            //        console.log(data);
            //        console.log(textStatus);
            //        console.log(jqXHR);
            //        console.log(that);

            if (typeof success_callback == "function")
            {
                success_callback(that, data);
            }
            // alert(data);
            if (data === undefined || data === null || data === "")
            {
                //display warning
            } else
            {

            }
        }).fail(function (jqXHR, textStatus, errorThrown) {

            //       console.log(jqXHR);
            //      console.log(textStatus);
            //       console.log(errorThrown);

            //       console.log(jqXHR.responseJSON.error)

            setUpNotifier("error.png", "Warning", jqXHR.responseJSON.error[0]);

            $(that).val($(that).data('initial-val'));
        })
    });
}
// JQyuery version of ui_ajax_checkbox.

// JQyuery version of ui_ajax_checkbox.

jQuery.fn.extend({
    ui_ajax_checkbox: function (success_callback) {
        return this.each(function () {
            $(this).bind("click", function (event) {

                event.stopPropagation(); // prevent click from propagation to other actions.

            }).bind("change", function (event) {


                dataUrl = this.getAttribute("data-url");
                dataMethod = this.getAttribute("data-method");
                dataType = this.getAttribute("data-type");
                isChecked = $(this).is(':checked');
                dataClass = this.getAttribute("data-class");
                fieldName = this.getAttribute("name");
                checkType = this.getAttribute("data-check-type");
                checkBoxValue = this.getAttribute("checkbox_value");
                
                var that = this;
                
                var dataObj = {};
                dataObj[dataClass] = {};
                if (checkType == "boolean")
                {
                    dataObj[dataClass][fieldName] = (isChecked ? 1 : 0)
                } else
                {
                    dataObj[dataClass][fieldName] = (isChecked ? checkBoxValue : "")
                }


//alert(this.getAttribute("data-id"));

                $.ajax({
                    url: dataUrl, // controller + "/update",
                    dataType: dataType,
                    type: dataMethod,
                    data: dataObj
                }).success(function (data, textStatus, jqXHR)
                {
                    
                    //  console.log(data);
                    //  console.log(textStatus);
                    //  console.log(jqXHR);
                    //  console.log(that);

                    if (typeof success_callback == "function")
                    {
                        success_callback(that, data);
                    }

                    if (data === undefined || data === null || data === "")
                    {
//display warning
                    } else
                    {

                    }

// alert(data);
                    if (data === undefined || data === null || data === "")
                    {
//display warning
                    } else
                    {

                    }
                }).fail(function (jqXHR, textStatus, errorThrown) {

                    console.log(jqXHR);
                    console.log(textStatus);
                    console.log(errorThrown);
                    console.log(jqXHR.responseJSON.error)

                    setUpNotifier("error.png", "Warning", jqXHR.responseJSON.error[0]);
                    $(that).val($(that).data('initial-val'));
                });
            });
        });
    }
});



function ui_ajax_checkbox(success_callback) {

    $("input.ui-ajax-checkbox").bind("click", function (event) {

        event.stopPropagation(); // prevent click from propagation to other actions.

    }).bind("change", function (event) {


        dataUrl = this.getAttribute("data-url");
        dataMethod = this.getAttribute("data-method");
        dataType = this.getAttribute("data-type");
        isChecked = $(this).is(':checked');
        dataClass = this.getAttribute("data-class");
        fieldName = this.getAttribute("name");
        checkType = this.getAttribute("data-check-type");
        checkBoxValue = this.getAttribute("checkbox_value");
        var dataObj = {};
        dataObj[dataClass] = {};
        if (checkType == "boolean")
        {
            dataObj[dataClass][fieldName] = (isChecked ? 1 : 0)
        } else
        {
            dataObj[dataClass][fieldName] = (isChecked ? checkBoxValue : "")
        }


        //alert(this.getAttribute("data-id"));

        $.ajax({
            url: dataUrl, // controller + "/update",
            dataType: dataType,
            type: dataMethod,
            data: dataObj
        }).success(function (data, textStatus, jqXHR)
        {
            var that = this;
            //  console.log(data);
            //  console.log(textStatus);
            //  console.log(jqXHR);
            //  console.log(that);

            if (typeof success_callback == "function")
            {
                success_callback(that, data);
            }

            if (data === undefined || data === null || data === "")
            {
                //display warning
            } else
            {

            }

            // alert(data);
            if (data === undefined || data === null || data === "")
            {
                //display warning
            } else
            {

            }
        }).fail(function (jqXHR, textStatus, errorThrown) {

            console.log(jqXHR);
            console.log(textStatus);
            console.log(errorThrown);
            console.log(jqXHR.responseJSON.error)

            setUpNotifier("error.png", "Warning", jqXHR.responseJSON.error[0]);
            $(that).val($(that).data('initial-val'));
        });
    });
}


function ui_ajax_settings_select(success_callback) {

    $("select.ui-ajax-settings-select").bind("change", function () {
        selected_item = $(this).val();
        controller = this.getAttribute("data-path")
        that = this

        //alert(this.getAttribute("data-id"));


        $.ajax({
            url: controller, // controller + "/update",
            dataType: "json",
            type: "PUT",
            data: "id=" + this.getAttribute("data-id") + "&settings[" + this.getAttribute("name") + "=" + selected_item,
            success: function (data, textStatus, jqXHR)
            {
                //  console.log(data);
                //  console.log(textStatus);
                //  console.log(jqXHR);
                //  console.log(that);

                if (typeof success_callback == "function")
                {
                    success_callback(that, data);
                }
                // alert(data);
                if (data === undefined || data === null || data === "")
                {
                    //display warning
                } else
                {

                }
            },
            fail: function (jqXHR, textStatus, errorThrown) {
                setUpNotifier("error.png", "Warning", textStatus);
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

function createButtonList(call_backs, buttons_to_build)
{
    button_list = {};
    $.each(buttons_to_build.split(","), function (index, value) {
        fixed_value = value.trim().replace(/ /g, "_");
        button_list[value.trim()] = {
            text: value.trim(),
            id: "dialog-" + fixed_value + "-button",
            click: function () {
// Do what needs to be done to complete 
                if (typeof (call_backs[value.trim()]) == "function")
                {
                    call_backs[value.trim()]();
                }
            }
        };
    });
    console.log(button_list);
    return (button_list);
}

function createAppDialogUtil(theContent, dialog_id, completion_callback, completion_button, beforeclose_callback) {

//  console.log(typeof (completion_button))

    var completion_button = (typeof (completion_button) == "undefined") ? "Close" : completion_button

    //  console.log(typeof (completion_button));
    //  console.log(completion_button);


    if ($("#" + dialog_id).length == 0)
    {
        var dialogContainer = "<div id='" + dialog_id + "'></div>";
        $("body").append($(dialogContainer));
    } else
    {
        dialogContainer = $("#" + dialog_id);
    }
// $('#app-dialog').html(theContent);
    theContent = '<input type="hidden" autofocus="autofocus" />' + theContent

    $('#' + dialog_id).html(theContent);
    theHeight = $('#' + dialog_id + ' #dialog-height').text() || "500";
    theWidth = $('#' + dialog_id + ' #dialog-width').text() || "500";
    theTitle = $('#' + dialog_id + ' #dialog-name').html() || "Edit";
    theAppDialog = $('#' + dialog_id).dialog({
        autoOpen: false,
        modal: true,
        title: theTitle,
        width: theWidth,
        height: theHeight,
        buttons: [
            {
                text: completion_button,
                click: function ()
                {
                    // Do what needs to be done to complete 

//                    if (typeof (completion_callback) == "function")
//                    {
//                        completion_callback();
//                    }

                    $(this).dialog("close");
                }
            }],
        beforeClose: function (event, ui)
        {
            var close_dialog = true;
            if (typeof (beforeclose_callback) == "function")
            {
                close_dialog = beforeclose_callback(event, ui);
            }
            return close_dialog;
        },
        close: function (event, ui) {

            if (typeof (completion_callback) == "function")
            {
                completion_callback();
            }

            $('#' + dialog_id).html("");
            $('#' + dialog_id).dialog("destroy");
            $('#' + dialog_id).remove();
            try {
                if (typeof (refresh_user_live_edit) == 'function') {
                    refresh_user_live_edit();
                }
            } catch (e) {
                // statements to handle any exceptions
                console.log(e); // pass exception object to error handler
            }

            //   alert('closed');
        },
        open: function (event, ui) {
            popUpAlertifExists();
            $(this).parent().find("span.ui-dialog-title").html(theTitle)
        },
        create: function (event, ui) {
        }


    });
//    theAppDialog.dialog({
//        // title: theTitle,
//        width: theWidth,
//        height: theHeight
//    });

    // $(dialogContainer).parent().find("span.ui-dialog-title").replaceWith(theTitle)

    theAppDialog.dialog("open");
    return(theAppDialog)
}


function createAppDialogCancel(theContent, dialog_id, completion_callback, completion_button) {

// console.log(typeof (completion_button))

    var completion_button = (typeof (completion_button) == "undefined") ? "Close" : completion_button

    //  console.log(typeof (completion_button));
    //  console.log(completion_button);


    if ($("#" + dialog_id).length == 0)
    {
        var dialogContainer = "<div id='" + dialog_id + "'></div>";
        $("body").append($(dialogContainer));
    } else
    {
        dialogContainer = $("#" + dialog_id);
    }
// $('#app-dialog').html(theContent);
    theContent = '<input type="hidden" autofocus="autofocus" />' + theContent

    $('#' + dialog_id).html(theContent);
    theHeight = $('#' + dialog_id + ' #dialog-height').text() || "500";
    theWidth = $('#' + dialog_id + ' #dialog-width').text() || "500";
    theTitle = $('#' + dialog_id + ' #dialog-name').html() || "Edit";
    theAppDialog = $('#' + dialog_id).dialog({
        autoOpen: false,
        modal: true,
        title: theTitle,
        width: theWidth,
        height: theHeight,
        buttons: [
            {
                text: "Cancel",
                click: function () {
                    $(this).dialog("close");
                },
                id: "cancle-button"

            },
            {
                text: completion_button,
                click: function ()
                {
                    // Do what needs to be done to complete 

                    if (typeof (completion_callback) == "function")
                    {
                        completion_callback();
                    }

                    $(this).dialog("close");
                }
            }
        ],
        close: function (event, ui) {



            $('#' + dialog_id).html("");
            $('#' + dialog_id).dialog("destroy");
            $('#' + dialog_id).html("");
            try {
                if (typeof (refresh_user_live_edit) == 'function') {
                    refresh_user_live_edit();
                }
            } catch (e) {
                // statements to handle any exceptions
                console.log(e); // pass exception object to error handler
            }

            //   alert('closed');
        },
        open: function (event, ui) {
            popUpAlertifExists();
            $(this).parent().find("span.ui-dialog-title").html(theTitle)
        },
        create: function (event, ui) {
        }


    });
//    theAppDialog.dialog({
//        // title: theTitle,
//        width: theWidth,
//        height: theHeight
//    });

    // $(dialogContainer).parent().find("span.ui-dialog-title").replaceWith(theTitle)

    theAppDialog.dialog("open");
    return(theAppDialog)
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
    } else
    {
        dialogContainer = $("#" + dialog_id);
    }

    button_list = createButtonList(call_backs, buttons_to_show_in);
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
    }
    ;
    for (var i = 0; i < $(me).children().length; i++) {
        findMyEvents($(me).children()[i])
    }
}

function updateCsrfToken() {
    $.ajax({
        url: "/site/get_csrf_meta_tags",
        dataType: "json",
        type: "GET",
        cache: false,
        success: function (data)
        {
            var old_token = $('[name="csrf-token"]').attr("content")
            //  console.log("token-updated")
            //  console.log("from: " + old_token)
            // console.log("  to: " + data.authenticity_token)

            $('[name="csrf-token"]').attr("content", data.authenticity_token)

        }
    })
}


function renderPartial(partial_name, element_to_update, completion_callback)
{
    $.ajax({
        url: "/site/render_partial",
        dataType: "html",
        type: "GET",
        cache: false,
        data: {partial_name: partial_name},
        success: function (data)
        {
            try
            {
                dataJSON = jQuery.parseJSON(data);
                session_invalid = true
            } catch (err)
            {
                session_invalid = false;
            }


            if (session_invalid || data === undefined || data === null || data === "")
            {
                window.location = "/?nocache=" + (new Date()).getTime();
                //display warning
            } else
            {
                if (element_to_update != "") {
                    $(element_to_update).html(data);
                }

                try {
                    if ((typeof eval("completion_callback") == 'function')) {
                        eval("completion_callback(data)");
                    }
                } catch (e) {
                    console.log(e); // pass exception object to error handler
                }

            }
        }
    });
}
