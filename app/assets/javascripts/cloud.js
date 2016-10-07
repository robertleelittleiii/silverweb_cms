/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


//
//  Animations for main screen
//
//

var interval;
var cloud1id;
var cloud2id;
var cloud3id;

function cloud1() {
    body_width = ($("body").width() + 150) + "px";
    $("#cloud1").animate({
        left: "+=" + body_width
    }, 10000).animate({
        left: "-150px"
    }, 0)

    // since the login screen doesn't have any watching of the system, we will use the animation timeout to allow 
    //a function to be called by the application to perform some login screen checks (if necessary).

    if (typeof LoginScreenCallback == "function") {
        LoginScreenCallback();
    }

    cloud1id = setTimeout("cloud1()", 10000);
}
function cloud2() {
    body_width = ($("body").width() + 250) + "px";

    $("#cloud2").animate({
        left: "+=" + body_width
    }, 9000).animate({
        left: "-250px"
    }, 0)
    cloud2id = setTimeout("cloud2()", 9000);
}
function cloud3() {
    body_width = ($("body").width() + 100) + "px";

    $("#cloud3").animate({
        left: "+=" + body_width
    }, 6000).animate({
        left: "-100px"
    }, 0)

    cloud3id = setTimeout("cloud3()", 6000);
}

function animation() {
    cloud1();
    cloud2();
    cloud3();
}
function stop_animation() {
    clearTimeout(cloud1id);
    clearTimeout(cloud2id);
    clearTimeout(cloud3id);
}

function initial_animation() {
    body_width = (($("body").width() - 350) / 2) + "px";
    $("#site-logo").css("left", body_width);
    $("#cloud-logo").css("left", body_width);


    $("#site-logo").animate({
        top: '75px'
    }, {
        queue: false,
        duration: 1000,
        easing: 'easeOutBounce'
    });


    $("#cloud-logo").animate({
        top: '350px'
    }, {
        queue: false,
        duration: 2000,
        easing: 'easeOutBounce'
    });

    $(".login-enclosure").animate({
        opacity: '1'
    }, {
        queue: false,
        duration: 2000,
        easing: 'easeInQuad'
    });

}


function toggle_login_box(display_now) {

    if (window.matchMedia("only screen and (max-width: 524px)").matches) {
        if (display_now) {
            $("#login-backdrop").hide();
            $(".login-enclosure").css("display", "block");
            $("#login-backdrop").fadeIn(500);
            $("form#login-form").css("top", "0px");
            $("input#name").focus();

        } else
        {
            $("form#login-form").css("top", "-350px");
            $(".login-enclosure").css("opacity", "0");
            $(".login-enclosure").css("display", "none");

            //$(".login-enclosure").fadeOut(500);
            //$("form#login-form").css("top","-350px");
            // $(".login-enclosure").slideUp(500);

        }
    } else {
        if (display_now) {
            $(".login-enclosure").fadeIn(500);
            $("input#name").focus();
        } else
        {
            $(".login-enclosure").fadeOut(500);

        }
    }
}




//
//
//  Login Check 
//
//

function checkLoginStatus()
{
    $.ajax({
        url: "/site/session_active",
        type: "POST",
        dataType: "html",
        success: function (data)
        {
            if (data == "true") {

                logedIn();
                stop_animation();
            } else
            {
                setTimeout("initial_animation()", 200);

                setTimeout("animation()", 500);

                loadLoginBox();

            }
        },
        done: function (msg) {
            alert("done");
            //$("#log").html( msg );
        },
        fail: function (jqXHR, textStatus) {
            alert("Request failed: " + textStatus);
        }
    });
}

//
//
// load login box if necessary
//
//


function loadLoginBox(url_to_goto) {

    $.ajax({
        url: "/site/login",
        type: "GET",
        dataType: "html",
        success: function (data)
        {
            loginContainer = "<div id='login-enclosure-container'></div>";

            if ($("#login-enclosure-container").length == 0)
            {
                $("body").append($(loginContainer));
            }

            $("#login-enclosure-container").html(data);
            $(".login-enclosure").hide();
            $(".login-enclosure").css("opacity", 1);
            $("form#login-form").css("top", "0px");
            $("input#name").focus();

            toggle_login_box(true);
            bindLoginClick(url_to_goto);
            bindLoginForgotLink();
            bindLoginRegisterLink();
            bindResetClick();
            bindRegisterClick();
            bindCancelClick();
            $("input.button-link").button();
            $("a.button-link").button();


        }
    });



}

function bindCancelClick() {
    $("a#cancel-button").click(function (e) {

        if (window.matchMedia("only screen and (max-width: 524px)").matches) {

            $("#login-backdrop").fadeOut(500);
            $("form#login-form").css("top", "-350px");
            $(".login-enclosure").fadeOut(500, function () {
                $("#login-enclosure-container").html("");
                $("#login-enclosure-container").remove();
            });

            //$(".login-enclosure").fadeOut(500);
            //$("form#login-form").css("top","-350px");
            // $(".login-enclosure").slideUp(500);

        } else {
            $("#login-backdrop").fadeOut(500);
            $(".login-enclosure").fadeOut(500, function () {
                $("#login-enclosure-container").html("");
                $("#login-enclosure-container").remove();
            });
        }

    });
}

function bindLogoutClick() {
    $('a#sign-out-button').bind('ajax:beforeSend', function (evt, xhr, settings) {
        // alert("ajax:before");  
        // console.log('ajax:before');
        // console.log(evt);
        // console.log(xhr);
        // console.log(settings);


    }).bind('ajax:success', function (evt, data, status, xhr) {
        //  alert("ajax:success"); 
        // console.log('ajax:success');
        // console.log(evt);
        // console.log(data);
        // console.log(data.message)
        // console.log(status);
        // console.log(xhr);
        updateFooterDiv();
        // updateAppDiv();
        updateSecurityDiv();
        // show_page();
        update_content();
        call_login_callbacks();

        if (!(typeof updateSiteDivsLogout == "undefined"))
        {
            updateSiteDivsLogout();
        }

    }).bind('ajax:error', function (evt, xhr, status, error) {
        // alert("ajax:failure"); 
        // console.log('ajax:error');
        // console.log(evt);
        // console.log(xhr);
        // console.log(status);
        // console.log(error);

    }).bind('ajax:complete', function (evt, xhr, status) {
        //    alert("ajax:complete");  
        // console.log('ajax:complete');
        // console.log(evt);
        // console.log(xhr);
        // console.log(status);


    });
}
function bindLoginClick(url_to_goto) {
    $('#login-form').bind('ajax:beforeSend', function (evt, xhr, settings) {
        // alert("ajax:before");  
        // console.log('ajax:before');
        // console.log(evt);
        // console.log(xhr);
        // console.log(settings);


    }).bind('ajax:success', function (evt, data, status, xhr) {
        //  alert("ajax:success"); 
        // console.log('ajax:success');
        // console.log(evt);
        // console.log(data);
        if (data.sucessfull) {
            login_sucessfull(url_to_goto);
        } else
        {
            $(".login-enclosure").effect("shake", {
                times: 3
            }, 800);

        }


        // console.log(status);
        // console.log(xhr);

    }).bind('ajax:error', function (evt, xhr, status, error) {
        // alert("ajax:failure"); 
        // console.log('ajax:error');
        // console.log(evt);
        // console.log(xhr);
        // console.log(status);
        // console.log(error);

    }).bind('ajax:complete', function (evt, xhr, status) {
        //    alert("ajax:complete");  
        // console.log('ajax:complete');
        // console.log(evt);
        // console.log(xhr);
        // // console.log(status);


    });

}

function bindResetClick() {
    $('#recover-form').bind('ajax:beforeSend', function (evt, xhr, settings) {
        // alert("ajax:before");  
        // console.log('ajax:before');
        // console.log(evt);
        // console.log(xhr);
        // console.log(settings);


    }).bind('ajax:success', function (evt, data, status, xhr) {
        //  alert("ajax:success"); 
        // console.log('ajax:success');
        // console.log(evt);
        // console.log(data);
        setUpPurrNotifier("Notice", data.message);
        $('div.login-form').toggleClass('flipped');
        $("input[name='name']").val("");

        // console.log(status);
        // console.log(xhr);

    }).bind('ajax:error', function (evt, xhr, status, error) {
        // alert("ajax:failure"); 
        // console.log('ajax:error');
        // console.log(evt);
        // console.log(xhr);
        // console.log(status);
        // console.log(error);

    }).bind('ajax:complete', function (evt, xhr, status) {
        //    alert("ajax:complete");  
        // console.log('ajax:complete');
        // console.log(evt);
        // console.log(xhr);
        // // console.log(status);


    });

}

function userLoggedIn() {
    $.ajax({
        url: "/site/session_active",
        type: "POST",
        dataType: "json",
        success: function (data)
        {
            if (data == true) {
                //  alert("do nothing");
            } else
            {
                window.location = "/?nocache=" + (new Date()).getTime();
                // alert("refresh to site");
            }
            // console.log(data);

        }
    });

}

function check_login_status() {
    check_login_status_time = $("#check_login_status").text();

    check_login_status_time = check_login_status_time == "" ? "10000" : check_login_status_time;

    if (typeof interval != "number") {
        interval = setInterval(function () {
            userLoggedIn();
        }, check_login_status_time);
    }

}

function login_sucessfull(url_to_goto) {

    //   toggle_login_box(false);

//    clearTimeout(cloud1id);
//    clearTimeout(cloud2id);
//    clearTimeout(cloud3id);
//
//    $("#cloud1").fadeOut(500);
//    $("#cloud2").fadeOut(500);
//    $("#cloud3").fadeOut(500);


//    body_width = $(document).width();
//    body_height = $(document).height();
//
//    $("#site-logo").animate({
//        top: '25px',
//        left: '100px'
//    }, {
//        queue: false,
//        duration: 1000,
//        easing: 'easeOutBounce'
//    });
//
//
//    $("#cloud-logo").animate({
//        top: (body_height - 124) + 'px',
//        left: (body_width - 500) + 'px'
//    }, {
//        queue: false,
//        duration: 1000,
//        easing: 'easeOutBounce'
//    });

    $(".login-enclosure").fadeOut(500, function () {
        if ($("#login-enclosure-container").length != 0) {
            $("#login-enclosure-container").html("");
            $("#login-enclosure-container").remove();
        }
    });




    updateFooterDiv();
    updateSecurityDiv();
    update_content();
    call_login_callbacks();
    // show_page();
    // if updateSiteDivs is defined for site then...

    if (!(typeof updateSiteDivsLogin == "undefined"))
    {
        updateSiteDivsLogin();
    }

    if (!(typeof url_to_goto == "undefined"))
    {
        window.location = url_to_goto
    } else
    {
        // updateAppDiv();

    }

    // check_login_status();


}
function logedIn() {



    body_width = $(document).width();
    body_height = $(document).height();

    $("#site-logo").animate({
        top: '25px',
        left: '100px'
    }, {
        queue: false,
        duration: 1000,
        easing: 'easeOutBounce'
    });


    $("#cloud-logo").animate({
        top: (body_height - 124) + 'px',
        left: (body_width - 500) + 'px'
    }, {
        queue: false,
        duration: 1000,
        easing: 'easeOutBounce'
    });

    updateFooterDiv();
    updateAppDiv();
    check_login_status();
}



function bindMyAccountClick()
{
    $("#my-account-link").click(function () {

        $("#grid-nav").fadeIn();
        $($currentApplicationId).removeClass("blowup");
        $(".grid_tabnav ul li").removeClass("hidden");

    });
    return(false);
}

function updateSecurityDiv()
{
    $.ajax({
        url: "/site/render_partial",
        dataType: "html",
        type: "GET",
        data: "partial_name=login_div.html",
        success: function (data)
        {
            //alert(data);
            if (data === undefined || data === null || data === "")
            {
                //display warning
            } else
            {
                if ($("div#admin-nav.normal").length > 0) {
                    $("div#admin-nav.normal #security-div").html(data);
                    $("div#admin-nav.small #security-div").html(data);
                } else
                {
                    $("#security-div").html(data);

                }
                bindMyAccountClick();
                bindCloseIframe();
                bindLoginButton();
                bindLogoutClick();
                bindMyAccount();
            }
        }
    });

}

function updateFooterDiv()
{


    $.ajax({
        url: "/site/render_partial",
        dataType: "html",
        type: "GET",
        data: "partial_name=footer.html",
        success: function (data)
        {
            //alert(data);
            if (data === undefined || data === null || data === "")
            {
                //display warning
            } else
            {
                $("#footer").html(data);
                bindMyAccountClick();
                bindCloseIframe();
            }
        }
    });

}
;
resultData = ""
function updateAppDiv() {
    // check and make sure that we are not using the CMS_dialog!
    if ($("div#layout-name").text() != "cms_dialog") {
        $.ajax({
            url: "/site/render_partial",
            dataType: "html",
            cache: false,
            type: "GET",
            data: "partial_name=/cms_interface/grid_tab_nav.html",
            success: function (data)
            {
                resultData = data;
                //alert(data);
                if (data === undefined || data === null || data === "")
                {
                    //display warning
                } else
                {

                    if ($("#nav-grid-links").length === 0) {
                        var gridContainer = "<div style='display:none' id='nav-grid-links'></div>";
                        $("body").prepend($(gridContainer));
                    }

                    $("#nav-grid-links").html(data);
                    $(".grid_tabnav ul li").removeClass("hidden");
                    // $("#grid-nav").fadeIn();
                    if (window.matchMedia("only screen and (max-width: 524px)").matches)
                    {
                        $("#nav-grid-links").fadeIn();
                        $("#grid-nav").css("top", "0px");
                    } else
                    {
                        $("#nav-grid-links").fadeIn();
                        $("#grid-nav").css("top", "0px");

                    }

                    bindAppClick();
                    bindCloseGrid();

                }
            }
        });
    }
}

function bindCloseGrid() {

    bindHideGrid();

    $("a.button-close").button({
        icons: {
            primary: "ui-icon-close"
        },
        text: false
    }).click(function () {
        $("#nav-grid-links").fadeOut();
    });

}

function bindHideGrid() {
    $("div.hide-grid").button({
        icons: {
            primary: "ui-icon-grip-solid-horizontal"
        },
        text: false
    }).click(function () {

        $("#grid-nav").css("top", "-500px");
        $("#nav-grid-links").fadeOut();

    });
}

function bindCloseIframe() {

    $("#hide-iframe").off("click").on("click", function () {
        $("#nav-grid-links").fadeIn();
        $("#application-space").addClass("hidden");
        $($currentApplicationId).removeClass("blowup");
        $(".grid_tabnav ul li").removeClass("hidden");
        $("#cloud-switch").fadeOut();

        clear_user_locks();

    });

}

function clear_user_locks() {

    $.ajax({
        url: "/admin/clear_user_locks",
        type: "POST",
        dataType: "html",
        success: function (data)
        {

        }
    });
}

function bindMyAccount() {
    if ($("div#admin-nav.normal").length > 0) {
        $("div#admin-nav #my-account").click(function () {
            updateAppDiv();
        });
    } else
    {
        $("div#admin-nav.normal #my-account").click(function () {
            updateAppDiv();
            // $("#nav-grid-links").fadeIn();
        });
        $("div#admin-nav.small #my-account").click(function () {
            updateAppDiv();
        });
    }

}
function bindIconButtonClick() {
    $('.icon-button').click(function (e) {
        if (window.matchMedia("only screen and (max-width: 524px)").matches) {
            the_url = $(this).attr("href").replace("window", "");
            // console.log(the_url);
            // e.stopPropagation(); 
            window.location = the_url;

        }
    })
}

function bindAppClick() {

    bindIconButtonClick();

    $('.icon-button').bind('ajax:beforeSend', function (evt, xhr, settings) {
        // alert("ajax:before");  
        // console.log('ajax:before');
        // console.log(evt);
        // console.log(xhr);
        // console.log(settings);
        // console.log(this);
        $(this).find("#ajax-wait img").show();

    }).bind('ajax:success', function (evt, data, status, xhr) {
        //  alert("ajax:success"); 
        $(this).find("#ajax-wait img").hide();

        // console.log('ajax:success');
        // console.log(evt);
        // console.log(data);
        // console.log(this);
        // console.log(this.href);
        $currentApplicationId = $(this).parent();
        $(this).parent().addClass("blowup");
        $(".grid_tabnav ul li").addClass("hidden");
        $("div#nav-grid-links").fadeOut();

        //$("#grid-nav").fadeOut();

        require("jquery.urlparser.js");

        var windowType = $.url(this.href).param("window_type");
        var theController = $.url(this.href).segment(1);
        var theAction = $.url(this.href).segment(2) || "index"



        if (windowType == "iframe") {
            //   alert("This is an iframe app.");

            var thisApp = createiFrameOverlay(theController, data, this.href);
            $("#cloud-switch").fadeIn();
            updateFooterDiv();
        } else {

            if (windowType == "app")

            {
                var thisApp = createAppOverlay(theController, data);

                //   alert("This is an app");
            } else
            {
                //   alert("this is a dialog!")
                //var thisDialog = createEditDialog(data);
                var thisDialog = createAppDialog(data, "app-dialog", {
                    completion: function completionCallback() {
                        $("div#nav-grid-links").fadeIn();
                        $($currentApplicationId).removeClass("blowup");
                        $(".grid_tabnav ul li").removeClass("hidden");

                    }}, "Submit,Save as Draft,Cancel");

                thisDialog.dialog('open');

                $(thisDialog).find(".best_in_place").best_in_place();

                thisDialog.scrollTop(0);

                //// console.log(status);
                //// console.log(xhr);

                //// console.log(this.href);

                requireCss(theController + "/" + (theAction == 'index' ? 'index_' : theAction) + ".css");
                require(theController + "/" + (theAction == 'index' ? 'index_' : theAction) + ".js");

                //// console.log(theController + "_" + theAction + "_callDocumentReady");

                try
                {
                    if ((typeof (theController + "_" + theAction + "_callDocumentReady") == 'function') | (typeof (eval(theController + "_" + theAction + "_callDocumentReady")) == 'function')) {
                        eval(theController + "_" + theAction + "_callDocumentReady()");
                    }
                } catch (e) {
                    // statements to handle any exceptions
                    // console.log(e); // pass exception object to error handler
                }

            }
        }

        //// console.log(status);
        //// console.log(xhr);

        //// console.log(this.href);

        //// console.log(theController + "_" + theAction + "_callDocumentReady");


    }).bind('ajax:error', function (evt, xhr, status, error) {
        // alert("ajax:failure"); 
        // console.log('ajax:error');
        // console.log(evt);
        // console.log(xhr);
        // console.log(status);
        // console.log(error);

        $(this).find("#ajax-wait img").hide();
        setUpPurrNotifier("Network Error", "A network error has occured, please click the icon again.")

    }).bind('ajax:complete', function (evt, xhr, status) {
        //    alert("ajax:complete");  
        // console.log('ajax:complete');
        // console.log(evt);
        // console.log(xhr);
        $('#edit-dialog').scrollTop(0);

        // // console.log(status);


    });

}

// **********************************
//
//
//  Create iFrame Overlay
//
// **********************************

function createiFrameOverlay(appName, theContent, theURL) {

    var theOverlay = '<iframe class="iframe-application" id="' + appName + '-app-id" src="' + theURL + '"> </iframe>'
    $("#application-space").html("");
    $("#application-space").append($(theOverlay));

    $('#application-space').hide();

    $('#application-space').addClass("hidden");
    $('#application-space').show();

    $('#application-space').removeClass("hidden");

// $('#'+appName+'-app-id').html(theContent);


}
;

// **********************************
//
//
//  Create App Overlay
//
// **********************************

function createAppOverlay(appName, theContent) {

    var theOverlay = '<div id="' + appName + '-app-id"> </div>'


    if ($('#' + appName + '-app-id').length == 0)
    {
        $("#page").append($(theOverlay));

    }
    $('#' + appName + '-app-id').html(theContent);


}
;
// ************************************    
//
// Create Edit Dialog Box
//
// ************************************    

function createEditDialog(theContent) {

    // $('#edit-dialog').html(theContent);


    var theContent = '<input type="hidden" autofocus="autofocus" />' + theContent
    var theEditDialog = $('#edit-dialog').dialog({
        autoOpen: false,
        modal: true,
        //show: 'fade', 
        //hide:  'fade',
        buttons: {
            "Close": function () {
                // Do what needs to be done to complete 
                $(this).dialog("close");
            }
        },
        close: function (event, ui) {
            $($currentApplicationId).removeClass("blowup");
            $(".grid_tabnav ul li").removeClass("hidden");
            $('#edit-dialog').dialog("destroy");
        },
        open: function (event, ui)
        {
            $("#tabs").tabs();
            popUpAlertifExists();
        }


    });

    $('#edit-dialog').html(theContent);

    theHeight = $('#dialog-height').text() || "500";
    theWidth = $('#dialog-width').text() || "500";
    theTitle = $('#dialog-name').text() || "Edit";

    theEditDialog.dialog({
        title: theTitle,
        width: theWidth,
        height: theHeight
    });

    return(theEditDialog)
}


//
//
// 3d login recovery box
//
//
function bindLoginForgotLink() {
    $('.forgot-link').click(function (e) {

        var formContainer = $('div.login-form');

        // Flipping the forms
        formContainer.toggleClass('flipped');

        // If there is no CSS3 3D support, simply
        // hide the login form (exposing the recover one)
        if (!$.support.css3d) {
            $('#login').toggle();
        }
        e.preventDefault();
    });
}

function bindLoginRegisterLink() {
    $('.register-link').click(function (e) {

        var formContainer = $('div.login-form');

        // Flipping the forms
        formContainer.toggleClass('flipped-register');

        // If there is no CSS3 3D support, simply
        // hide the login form (exposing the recover one)
        if (!$.support.css3d) {
            $('#login').toggle();
        }
        e.preventDefault();
    });
}

function bindRegisterClick() {
    $('#registration-form').bind('ajax:beforeSend', function (evt, xhr, settings) {
        // alert("ajax:before");  
        // console.log('ajax:before');
        // console.log(evt);
        // console.log(xhr);
        // console.log(settings);


    }).bind('ajax:success', function (evt, data, status, xhr) {
        //  alert("ajax:success"); 
        // console.log('ajax:success');
        // console.log(evt);
        // console.log(data);
        setUpPurrNotifier("Notice", data.message);
        if (data.sucessfull) {
            login_sucessfull();
        } else
        {
            $('div.login-form').toggleClass('flipped-register');
            $("input[name='name']").val("");
        }
        // console.log(status);
        // console.log(xhr);

    }).bind('ajax:error', function (evt, xhr, status, error) {
        // alert("ajax:failure"); 
        // console.log('ajax:error');
        // console.log(evt);
        // console.log(xhr);
        // console.log(status);
        // console.log(error);

    }).bind('ajax:complete', function (evt, xhr, status) {
        //    alert("ajax:complete");  
        // console.log('ajax:complete');
        // console.log(evt);
        // console.log(xhr);
        // // console.log(status);


    });

}

function bindLoginButton() {

    $('div#sign-in-button').click(function (e) {
        loadLoginBox();
    });

}

function call_document_ready(theAction) {

    var the_function = theAction + "_callDocumentReady()";

    try
    {
        eval(the_function);
    } catch (err)
    {

    }
}


function show_page(page_id) {

    if (typeof page_id === 'undefined')
    {
        page_id = $("div#page-id").first().text()
        if (page_id === "") {
            location.reload(true);
            return
        }
    }
    var url = "site/show_page?id=" + page_id
    $.ajax({
        url: url,
        type: 'get',
        success: function (data)
        {
            $("div#content").html(data);
            call_document_ready_on_show_page();
            enablePageEdit();
            enableSliderEdit();
        }
    });

}

function call_login_callbacks() {

    var data_update_url = $("div#post-login-callback").attr('data-post-login-callback');

    try {
        if (typeof eval(data_update_url) == "function") {
            eval(data_update_url + "()")
        }
    } catch (err)
    {

    }

}

function update_content() {

    var data_update_url = $("div#data-reload").attr('data-page-params');
    var data_content_update_call = $("div#data-reload").attr('data-page-update');
    var data_additional = $("div#data-reload").attr('data-additional');

    if (typeof data_update_url === 'undefined')
    {
        if ($("div#nav-grid-links").css('display') != "none") {
            location.reload(true);
            return
        }
    }

    $.ajax({
        url: data_update_url,
        type: 'get',
        success: function (data)
        {
            $("div#content").html(data);
            try {
                if (typeof eval(data_content_update_call) == "function") {
                    eval(data_content_update_call + "()")
                }
            } catch (err)
            {

            }
            try {
                if (typeof (data_content_update_call + "_callDocumentReady") != undefined) {
                    if (typeof eval(data_content_update_call + "_callDocumentReady") == "function") {
                        eval(data_content_update_call + "_callDocumentReady()")
                    }
                }
            } catch (err)
            {

            }

            try {
                if (typeof eval(data_additional) == "function") {
                    eval(data_additional + "()")
                }
            } catch (err)
            {

            }
            try {
                if (typeof eval(data_additional + "_callDocumentReady") == "function") {
                    eval(data_additional + "_callDocumentReady()")
                }
            } catch (err)
            {
            }
        }
    });

}


// reset box creation

function toggle_reset_box(display_now) {

    if (window.matchMedia("only screen and (max-width: 524px)").matches) {
        if (display_now) {
            $("#login-backdrop").hide();
            $("div.reset-enclosure").css("display", "block");
            $("#login-backdrop").fadeIn(500);
            $("form#reset-form").css("top", "0px");
            $("input#password").focus();

        } else
        {
            $("form#reset-form").css("top", "-350px");
            $(".reset-enclosure").css("opacity", "0");
            $(".reset-enclosure").css("display", "none");

            //$(".login-enclosure").fadeOut(500);
            //$("form#login-form").css("top","-350px");
            // $(".login-enclosure").slideUp(500);

        }
    } else {
        if (display_now) {
            $(".reset-enclosure").fadeIn(500);
            $("input#password").focus();
        } else
        {
            $("#login-backdrop").hide();
            $(".reset-enclosure").fadeOut(500);

        }
    }
}


function bindSubmitClick() {
    $('#reset-form').bind('ajax:beforeSend', function (evt, xhr, settings) {
        // alert("ajax:before");  
        // console.log('ajax:before');
        // console.log(evt);
        // console.log(xhr);
        // console.log(settings);


    }).bind('ajax:success', function (evt, data, status, xhr) {
        //  alert("ajax:success"); 
        console.log('ajax:success');
        console.log(evt);
        console.log(data);

        switch (data.sucessfull) {
            case 1: // true, and successfull.
            {
                setUpPurrNotifier("Notice", data.message);
                toggle_reset_box(false);
                login_sucessfull();
                break;
            }
            case 0: // false and not able to continue 
            {
                setUpPurrNotifier("Notice", data.message);
                toggle_reset_box(false);
                break;
            }
            case -1: // false, but user can try again.
            {
                setUpPurrNotifier("Notice", data.message);
                break;
            }
            default:
            {
                // do nothing
            }
        }

        // console.log(status);
        // console.log(xhr);

    }
    ).bind('ajax:error', function (evt, xhr, status, error) {
        // alert("ajax:failure"); 
        // console.log('ajax:error');
        // console.log(evt);
        // console.log(xhr);
        // console.log(status);
        // console.log(error);

    }).bind('ajax:complete', function (evt, xhr, status) {
        //    alert("ajax:complete");  
        // console.log('ajax:complete');
        // console.log(evt);
        // console.log(xhr);
        // // console.log(status);


    });

}

function loadResetBox(reset_code) {

    $.ajax({
        url: "/site/reset",
        type: "GET",
        dataType: "html",
        data: {"reset_code": reset_code},
        success: function (data)
        {
            resetContainer = "<div id='reset-enclosure-container'></div>";

            if ($("#reset-enclosure-container").length == 0)
            {
                $("body").append($(resetContainer));
            }

            $("#reset-enclosure-container").html(data);
            $(".reset-enclosure").hide();
            $(".reset-enclosure").css("opacity", 1);
            $("form#reset-form").css("top", "0px");
            $("input#password").focus();

            toggle_reset_box(true);
            bindSubmitClick();
            bindResetCancelClick();
            $("input.button-link").button();
            $("a.button-link").button();


        }
    });



}


function bindResetCancelClick() {
    $("a#cancel-reset-button").click(function (e) {

        if (window.matchMedia("only screen and (max-width: 524px)").matches) {

            $("#login-backdrop").fadeOut(500);
            $("form#reset-form").css("top", "-350px");
            $(".reset-enclosure").fadeOut(500, function () {
                $("#reset-enclosure-container").html("");
                $("#reset-enclosure-container").remove();
            });

            //$(".login-enclosure").fadeOut(500);
            //$("form#login-form").css("top","-350px");
            // $(".login-enclosure").slideUp(500);

        } else {
            $("#login-backdrop").fadeOut(500);
            $(".reset-enclosure").fadeOut(500, function () {
                $("#reset-enclosure-container").html("");
                $("#reset-enclosure-container").remove();
            });
        }

    });
}
function process_admin_actions() {
    if ($("adminaction").size() > 0) {
        $("div#notice").text("");
        var action = $("adminaction").attr("action");
        var param = $("adminaction").attr("param");
        switch (action) {
            case "reset":
            {
                loadResetBox(param);
                console.log("found admin action!");
                break;
            }
            default:
            {
                // do nothing
            }
        }

    }
}