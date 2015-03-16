/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


//
//  Animations for main screen
//
//

var interval;

function cloud1() {
    body_width = ($("body").width() + 150) + "px";
    $("#cloud1").animate({
        left: "+=" + body_width
    }, 10000).animate({
        left: "-150px"
    }, 0)
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
    if (display_now) {
        $(".login-enclosure").fadeIn(500);
    }
    else
    {
        $(".login-enclosure").fadeOut(500);

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

            }
            else
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


function loadLoginBox() {

    $.ajax({
        url: "/site/login",
        type: "POST",
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
            toggle_login_box(true);
            bindLoginClick();
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
        $("#login-backdrop").fadeOut(500);
        $(".login-enclosure").fadeOut(500, function () {
            $("#login-enclosure-container").html("");
            $("#login-enclosure-container").remove();
        });
    });
}

function bindLogoutClick() {
    $('a#sign-out-button').bind('ajax:beforeSend', function (evt, xhr, settings) {
        // alert("ajax:before");  
        console.log('ajax:before');
        console.log(evt);
        console.log(xhr);
        console.log(settings);


    }).bind('ajax:success', function (evt, data, status, xhr) {
        //  alert("ajax:success"); 
        console.log('ajax:success');
        console.log(evt);
        console.log(data);
        console.log(data.message)
        console.log(status);
        console.log(xhr);
        updateFooterDiv();
        updateAppDiv();
        updateSecurityDiv();
        show_page();

    }).bind('ajax:error', function (evt, xhr, status, error) {
        // alert("ajax:failure"); 
        console.log('ajax:error');
        console.log(evt);
        console.log(xhr);
        console.log(status);
        console.log(error);

    }).bind('ajax:complete', function (evt, xhr, status) {
        //    alert("ajax:complete");  
        console.log('ajax:complete');
        console.log(evt);
        console.log(xhr);
        console.log(status);


    });
}
function bindLoginClick() {
    $('#login-form').bind('ajax:beforeSend', function (evt, xhr, settings) {
        // alert("ajax:before");  
        console.log('ajax:before');
        console.log(evt);
        console.log(xhr);
        console.log(settings);


    }).bind('ajax:success', function (evt, data, status, xhr) {
        //  alert("ajax:success"); 
        console.log('ajax:success');
        console.log(evt);
        console.log(data);
        if (data.sucessfull) {
            login_sucessfull();
        }
        else
        {
            $(".login-enclosure").effect("shake", {
                times: 3
            }, 800);

        }


        console.log(status);
        console.log(xhr);

    }).bind('ajax:error', function (evt, xhr, status, error) {
        // alert("ajax:failure"); 
        console.log('ajax:error');
        console.log(evt);
        console.log(xhr);
        console.log(status);
        console.log(error);

    }).bind('ajax:complete', function (evt, xhr, status) {
        //    alert("ajax:complete");  
        console.log('ajax:complete');
        console.log(evt);
        console.log(xhr);
        // console.log(status);


    });

}

function bindResetClick() {
    $('#recover-form').bind('ajax:beforeSend', function (evt, xhr, settings) {
        // alert("ajax:before");  
        console.log('ajax:before');
        console.log(evt);
        console.log(xhr);
        console.log(settings);


    }).bind('ajax:success', function (evt, data, status, xhr) {
        //  alert("ajax:success"); 
        console.log('ajax:success');
        console.log(evt);
        console.log(data);
        setUpPurrNotifier("Notice", data.message);
        $('div.login-form').toggleClass('flipped');
        $("input[name='name']").val("");

        console.log(status);
        console.log(xhr);

    }).bind('ajax:error', function (evt, xhr, status, error) {
        // alert("ajax:failure"); 
        console.log('ajax:error');
        console.log(evt);
        console.log(xhr);
        console.log(status);
        console.log(error);

    }).bind('ajax:complete', function (evt, xhr, status) {
        //    alert("ajax:complete");  
        console.log('ajax:complete');
        console.log(evt);
        console.log(xhr);
        // console.log(status);


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
            }
            else
            {
                window.location = "/"
                // alert("refresh to site");
            }
            console.log(data);

        }
    });

}

function check_login_status() {
    check_login_status = $("#check_login_status").text();

    if (typeof interval != "number") {
        interval = setInterval(function () {
            userLoggedIn();
        }, check_login_status);
    }

}

function login_sucessfull() {

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
    updateAppDiv();
    updateSecurityDiv();
    show_page();
    

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
            }
            else
            {
                $("#security-div").html(data);
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
            }
            else
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

    $.ajax({
        url: "/site/render_partial",
        dataType: "html",
        type: "GET",
        data: "partial_name=/cms_interface/grid_tab_nav.html",
        success: function (data)
        {
            resultData = data;
            //alert(data);
            if (data === undefined || data === null || data === "")
            {
                //display warning
            }
            else
            {
                if ($("#nav-grid-links").length === 0) {
                    var gridContainer = "<div style='display:none' id='nav-grid-links'></div>";
                    $("body").prepend($(gridContainer));
                }

                $("#nav-grid-links").html(data);
                $(".grid_tabnav ul li").removeClass("hidden");
                // $("#grid-nav").fadeIn();
                $("#nav-grid-links").fadeIn();

                bindAppClick();
                bindCloseGrid();

            }
        }
    });

}

function bindCloseGrid() {
    $("a.button-close").button({
        icons: {
            primary: "ui-icon-close"
        },
        text: false
    }).click(function () {

        $("#nav-grid-links").fadeOut();

    });

}

function bindCloseIframe() {
    $("#hide-iframe").click(function () {

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
    $("a#my-account").click(function () {
        updateAppDiv()
        // $("#nav-grid-links").fadeIn();

    });

}
function bindAppClick() {
    $('.icon-button').bind('ajax:beforeSend', function (evt, xhr, settings) {
        // alert("ajax:before");  
        console.log('ajax:before');
        console.log(evt);
        console.log(xhr);
        console.log(settings);
        console.log(this);
        $(this).find("#ajax-wait img").show();

    }).bind('ajax:success', function (evt, data, status, xhr) {
        //  alert("ajax:success"); 
        $(this).find("#ajax-wait img").hide();

        console.log('ajax:success');
        console.log(evt);
        console.log(data);
        console.log(this);
        console.log(this.href);
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
        }
        else {

            if (windowType == "app")

            {
                var thisApp = createAppOverlay(theController, data);

                //   alert("This is an app");
            }
            else
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
            }
        }
        
        console.log(status);
        console.log(xhr);

        console.log(this.href);

        requireCss(theController + "/" + theAction + ".css");
        require(theController + "/" + ( theAction=='index' ? 'index+' : theAction )+ ".js");

        console.log(theController + "_" + theAction + "_callDocumentReady");
        
        try
        {
            if ((typeof (theController + "_" + theAction + "_callDocumentReady") == 'function') | (typeof (eval(theController + "_" + theAction + "_callDocumentReady")) == 'function')) {
                eval(theController + "_" + theAction + "_callDocumentReady()");
            }
        }
        catch (e) {
            // statements to handle any exceptions
            console.log(e); // pass exception object to error handler
        }






    }).bind('ajax:error', function (evt, xhr, status, error) {
        // alert("ajax:failure"); 
        console.log('ajax:error');
        console.log(evt);
        console.log(xhr);
        console.log(status);
        console.log(error);

        $(this).find("#ajax-wait img").hide();
        setUpPurrNotifier("Network Error", "A network error has occured, please click the icon again.")

    }).bind('ajax:complete', function (evt, xhr, status) {
        //    alert("ajax:complete");  
        console.log('ajax:complete');
        console.log(evt);
        console.log(xhr);
        $('#edit-dialog').scrollTop(0);

        // console.log(status);


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
        console.log('ajax:before');
        console.log(evt);
        console.log(xhr);
        console.log(settings);


    }).bind('ajax:success', function (evt, data, status, xhr) {
        //  alert("ajax:success"); 
        console.log('ajax:success');
        console.log(evt);
        console.log(data);
        setUpPurrNotifier("Notice", data.message);
        if (data.sucessfull) {
            login_sucessfull();
        }
        else
        {
            $('div.login-form').toggleClass('flipped-register');
            $("input[name='name']").val("");
        }
        console.log(status);
        console.log(xhr);

    }).bind('ajax:error', function (evt, xhr, status, error) {
        // alert("ajax:failure"); 
        console.log('ajax:error');
        console.log(evt);
        console.log(xhr);
        console.log(status);
        console.log(error);

    }).bind('ajax:complete', function (evt, xhr, status) {
        //    alert("ajax:complete");  
        console.log('ajax:complete');
        console.log(evt);
        console.log(xhr);
        // console.log(status);


    });

}

function bindLoginButton() {

    $('#sign-in-button').click(function (e) {
        loadLoginBox();
    });

}

function call_document_ready(theAction) {

    var the_function = theAction + "_callDocumentReady()";

    try
    {
        eval(the_function);
    }
    catch (err)
    {

    }
}

function show_page(page_id) {

    if (typeof page_id === 'undefined')
    {
        page_id = $("div#page-id").first().text()
        if (page_id === "") {
            return
        }
    }
    var url = "site/show_page?id=" + page_id
    $.ajax({
        url: url,
        type: 'get',
        success: function (data)
        {
            $("div#content").html(data)
            enablePageEdit();

        }
    });

}