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
var allow_login_check = true;
var allow_login_check_timer = ""

function cloud1() {
    var body_width = ($("body").width() + 150) + "px";
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
    cloud1id = undefined;

    cloud1id = setTimeout("cloud1()", 10000);
}

function cloud2() {
    var body_width = ($("body").width() + 250) + "px";

    $("#cloud2").animate({
        left: "+=" + body_width
    }, 9000).animate({
        left: "-250px"
    }, 0)
    cloud2id = undefined;

    cloud2id = setTimeout("cloud2()", 9000);
}
function cloud3() {
    var body_width = ($("body").width() + 100) + "px";

    $("#cloud3").animate({
        left: "+=" + body_width
    }, 6000).animate({
        left: "-100px"
    }, 0)

    cloud3id = undefined;

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
    cloud1id = undefined;
    cloud2id = undefined;
    cloud3id = undefined;
}

function initial_animation() {
    body_width = (($("body").width() - 350) / 2);
    $("#site-logo").css("left", body_width + 35 + "px");
    $("#cloud-logo").css("left", body_width + "px");


    $("#site-logo").animate({
        top: '30px'
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

function sessionActive() {
    //   console.log("session active?")
    $.ajax({
        url: "/site/check_session",
        type: "POST",
        dataType: "json",
        success: function (data)
        {
            if (data.exists == true) {

                //         console.log("session active = true")
            } else
            {
                console.log("session active = false")
                window.location = "/?nocache=" + (new Date()).getTime();
            }
        },
        done: function (msg) {
            //        console.log("done");
            //$("#log").html( msg );
        },
        fail: function (jqXHR, textStatus) {
            //       console.log("Request failed: " + textStatus);
        }
    });

}


//
//
//  Login Check 
//
//

function checkLoginStatus()
{
    if (allow_login_check) {
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
}

//
//
// load login box if necessary
//
//


function loadLoginBox(url_to_goto, show_main_menu) {

    if ($("adminaction").size() == 0) {
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
                bindLoginClick(url_to_goto, show_main_menu);
                bindSubmitCodeClick(url_to_goto, show_main_menu);
                bindLoginForgotLink();
                bindLoginRegisterLink();
                bindLoginTwoFactorLink();
                bindResetClick();
                bindRegisterClick();
                bindCancelClick();
                $("input.button-link").button();
                $("a.button-link").button();


            }
        });

    }

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

function bindSubmitCodeClick(url_to_goto, show_main_menu) {

    {
        $('#two-factor-form').bind('ajax:beforeSend', function (evt, xhr, settings) {
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
            if (data.twofactor) {
                if (data.code_expired)
                {
                    $('div.login-form').toggleClass('flipped-two-factor');
                } 
                else 
                {

                    $(".login-enclosure").effect("shake", {
                        times: 3
                    }, 800);
                }
                // $('div.login-form').toggleClass('flipped-two-factor');
                setUpPurrNotifier("Notice", data.message);

            } else if (data.sucessfull) {
                login_sucessfull(url_to_goto, show_main_menu);
                setUpPurrNotifier("Notice", data.message);

            } else
            {
                $(".login-enclosure").effect("shake", {
                    times: 3
                }, 800);
                setUpPurrNotifier("Notice", data.message);

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
}

function bindLoginClick(url_to_goto, show_main_menu) {
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
        if (data.twofactor) {
            if (data.authpoint_methods && data.authpoint_methods.length > 1 && !data.authpoint_method) {
                // Multiple AuthPoint methods available, no preference — show method selection
                showAuthPointMethodSelection(data.authpoint_methods, url_to_goto, show_main_menu, data.message);
            } else if (data.authpoint_pending && data.authpoint_method === 'OTP') {
                // AuthPoint OTP flow: show the code entry form so user can type their OTP
                if (!$('div.login-form').hasClass('flipped-two-factor')) {
                  $('div.login-form').toggleClass('flipped-two-factor');
                }
                setUpPurrNotifier("Notice", data.message || "Enter the code from your AuthPoint app or hardware token.");
                $("input#code").focus();
                $("input#code").trigger("click");
            } else if (data.authpoint_pending) {
                // AuthPoint push or QR flow: show instruction and start polling.
                setUpPurrNotifier("Notice", data.message || "Please approve or scan the QR code in the AuthPoint app, then enter the code if prompted.");
                try {
                  if (data.authpoint_qrcode) {
                    // Flip to the two-factor panel so the user can enter the code after scanning
                    if (!$('div.login-form').hasClass('flipped-two-factor')) {
                      $('div.login-form').toggleClass('flipped-two-factor');
                    }
                    // Inject QR code above the two-factor form if not already present
                    if ($('#authpoint-qr-container-twofactor').length === 0) {
                      var _qrSrc = computeAuthPointQrSrc(data.authpoint_qrcode || '');
                      // Hidden container to show on hover
                      var qrBlock = '<div id="authpoint-qr-container-twofactor" class="loginArea"\
                                   style="display:none; position:fixed; top:50%; left:50%; transform:translate(-50%, -50%); z-index:10000; text-align:center; padding:16px; box-shadow: 0 10px 25px rgba(0,0,0,0.35);">' +
                                    '<div style="margin:5px 0 10px; font-weight:bold;">Scan this QR code with the AuthPoint app, then enter the code below if prompted.</div>' +
                                    '<img id="authpoint-qr" alt="AuthPoint QR Code" style="max-width:240px;" src="' + _qrSrc + '" />' +
                                    '</div>';
                      $('#two-factor-form').prepend(qrBlock);
                    } else {
                      $('#authpoint-qr').attr('src', computeAuthPointQrSrc(data.authpoint_qrcode));
                    }
                    // Ensure small QR icon exists next to the code field
                    if ($('#authpoint-qr-icon').length === 0) {
                      var qrIcon = '<span id="authpoint-qr-icon" title="Show QR Code" ' +
                                   'style="display:inline-block; vertical-align:middle; margin-left:6px; cursor:pointer; width:18px; height:18px;">' +
                                   '<svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true">' +
                                   '<path fill="#555" d="M3 3h8v8H3V3zm2 2v4h4V5H5zm6-2h8v8h-8V3zm2 2v4h4V5h-4zM3 13h8v8H3v-8zm2 2v4h4v-4H5zm10-2h2v2h-2v-2zm-2 2h2v2h-2v-2zm4 0h4v2h-4v-2zm-2 2h2v2h-2v-2zm4 0h2v6h-6v-2h4v-4z"/>' +
                                   '</svg>' +
                                   '</span>';
                      // Insert after the code input
                      var $codeInput = $('#two-factor-form input#code');
                      $codeInput.after(qrIcon);
                    }
                    // Bind hover handlers to show/hide the QR container
                    (function(){
                      var $icon = $('#authpoint-qr-icon');
                      var $container = $('#authpoint-qr-container-twofactor');
                      if (!$icon.data('hover-bound')) {
                        var hideTimer = null;
                        var scheduleHide = function(){ hideTimer = setTimeout(function(){ $container.stop(true,true).fadeOut(150); }, 150); };
                        var cancelHide = function(){ if (hideTimer) { clearTimeout(hideTimer); hideTimer = null; } };
                        $icon.on('mouseenter', function(){ cancelHide(); $container.stop(true,true).fadeIn(150); });
                        $icon.on('mouseleave', function(){ scheduleHide(); });
                        $container.on('mouseenter', function(){ cancelHide(); });
                        $container.on('mouseleave', function(){ scheduleHide(); });
                        $icon.data('hover-bound', true);
                      }
                    })();
                  } else {
                    // No QR; just show instruction on the current panel
                    $("#notice").text(data.message);
                  }
                } catch(e) {}
                // Start polling check_session until authenticated (works in parallel to code entry)
                if (window.authpointPollInterval) { clearInterval(window.authpointPollInterval); }
                window.authpointPollInterval = setInterval(function(){
                  $.ajax({
                    url: '/site/check_session',
                    type: 'POST',
                    dataType: 'json',
                    success: function(resp){
                      if (resp && resp.authenticated) {
                        clearInterval(window.authpointPollInterval);
                        // proceed as successful login
                        login_sucessfull(url_to_goto, show_main_menu);
                      }
                    }
                  });
                }, 3000);
            } else {
                // Legacy 2FA code-entry flow
                $('div.login-form').toggleClass('flipped-two-factor');
                setUpPurrNotifier("Notice", data.message);
                $("input#code").focus();
                $("input#code").trigger("click");
            }
        } else if (data.sucessfull) {
            login_sucessfull(url_to_goto, show_main_menu);
            setUpPurrNotifier("Notice", data.message);

        } else
        {
            $(".login-enclosure").effect("shake", {
                times: 3
            }, 800);
            setUpPurrNotifier("Notice", data.message);

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

// Show AuthPoint method selection using the CSS flip panel
function showAuthPointMethodSelection(methods, url_to_goto, show_main_menu, message) {
    var methodLabels = { 'Push': 'Push Notification', 'OTP': 'One-Time Password (OTP)', 'QRCode': 'QR Code' };
    var $buttons = $('#authpoint-method-buttons');
    $buttons.empty();

    $.each(methods, function(i, method) {
      var label = methodLabels[method] || method;
      var id = 'authpoint-method-' + method.toLowerCase();
      var $radio = $('<div style="margin:6px 0; text-align:left; padding-left:30px;">' +
                     '<label style="cursor:pointer;"><input type="radio" name="authpoint_method" value="' + method + '" id="' + id + '" style="margin-right:8px;">' + label + '</label>' +
                     '</div>');
      $buttons.append($radio);
    });

    // Select first option by default
    $buttons.find('input[type=radio]:first').prop('checked', true);

    // Continue button — submit selected radio
    $('#authpoint-method-continue').off('click').on('click', function() {
      var chosen = $('input[name=authpoint_method]:checked').val();
      if (!chosen) return;
      var savePreference = $('#authpoint-save-preference').is(':checked');
      $('div.login-form').removeClass('flipped-authpoint-method');
      selectAuthPointMethod(chosen, savePreference, url_to_goto, show_main_menu);
    });

    // Back to login link
    $('.authpoint-method-back-link').off('click').on('click', function() {
      $('div.login-form').removeClass('flipped-authpoint-method');
    });

    // Flip to method selection panel
    if (!$('div.login-form').hasClass('flipped-authpoint-method')) {
      $('div.login-form').toggleClass('flipped-authpoint-method');
    }
    setUpPurrNotifier("Notice", message || "Please choose your authentication method.");
}

// POST the chosen method to the server and handle the response like a normal login_ajax response
function selectAuthPointMethod(method, savePreference, url_to_goto, show_main_menu) {
    var csrfToken = $('meta[name="csrf-token"]').attr('content');
    $.ajax({
      url: '/site/set_authpoint_method_ajax',
      type: 'POST',
      dataType: 'json',
      data: { authpoint_method: method, save_preference: savePreference ? 'true' : 'false' },
      headers: { 'X-CSRF-Token': csrfToken },
      success: function(data) {
        // Process the response the same way bindLoginClick does
        if (data.success && data.authpoint_method === 'OTP') {
          if (!$('div.login-form').hasClass('flipped-two-factor')) {
            $('div.login-form').toggleClass('flipped-two-factor');
          }
          setUpPurrNotifier("Notice", data.message || "Enter the code from your AuthPoint app or hardware token.");
          $("input#code").focus();
          $("input#code").trigger("click");
        } else if (data.success && data.authpoint_pending) {
          // Push or QR flow
          setUpPurrNotifier("Notice", data.message);
          if (data.authpoint_qrcode) {
            if (!$('div.login-form').hasClass('flipped-two-factor')) {
              $('div.login-form').toggleClass('flipped-two-factor');
            }
            // Inject QR code
            if ($('#authpoint-qr-container-twofactor').length === 0) {
              var _qrSrc = (typeof computeAuthPointQrSrc === 'function') ? computeAuthPointQrSrc(data.authpoint_qrcode) : data.authpoint_qrcode;
              var qrBlock = '<div id="authpoint-qr-container-twofactor" class="loginArea" ' +
                            'style="text-align:center; padding:16px;">' +
                            '<div style="margin:5px 0 10px; font-weight:bold;">Scan this QR code with the AuthPoint app, then enter the code below.</div>' +
                            '<img id="authpoint-qr" alt="AuthPoint QR Code" style="max-width:240px;" src="' + _qrSrc + '" />' +
                            '</div>';
              $('#two-factor-form').prepend(qrBlock);
            }
          }
          // Start polling for push/QR approval
          if (window.authpointPollInterval) { clearInterval(window.authpointPollInterval); }
          window.authpointPollInterval = setInterval(function(){
            $.ajax({
              url: '/site/check_session',
              type: 'POST',
              dataType: 'json',
              success: function(resp){
                if (resp && resp.authenticated) {
                  clearInterval(window.authpointPollInterval);
                  login_sucessfull(url_to_goto, show_main_menu);
                }
              }
            });
          }, 3000);
        } else {
          setUpPurrNotifier("Notice", data.message || "Authentication failed. Please try again.");
        }
      },
      error: function() {
        setUpPurrNotifier("Notice", "Authentication service temporarily unavailable.");
      }
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
    if ($("div#login-status").length > 0) {
        $.ajax({
            url: "/site/session_active",
            type: "POST",
            dataType: "json",
            success: function (data)
            {
                var page_login_status = $("div#login-status").text();
                if (data == true) {
                    updateCsrfToken();
                    if (page_login_status == "true") {
                        // do nothing

                    } else
                    {
                        login_sucessfull();
                    }
                } else
                {   // we were logged in but the server loged us off either by the cron job or by the user loging out on another window so refresh the page.
                    if (page_login_status == "true") {
                        window.location = "/?nocache=" + (new Date()).getTime();
                    } else
                    { // we are at the login screen, update the CSR to make sure when we login, the CSR is valid (it may have expired)
                        updateCsrfToken();
                    }
                    // alert("refresh to site");
                }
                // console.log(data);

            }
        });
    }
}

function check_login_status() {
    check_login_status_time = $("#check_login_status").text();

    check_login_status_time = check_login_status_time == "" ? "10000" : check_login_status_time;

    if (typeof interval != "number") {
        interval = setInterval(function () {
            if (allow_login_check) {
                userLoggedIn();
            }
        }, check_login_status_time);
    }

}


function set_my_timezone() {
    var tz = jstz.determine();
    $.ajax({
        method: "post",
        dataType: "json",
        url: '/site/set_time_zone?time_zone=' + tz.name(),
        cache: false,
        success: function (data)
        {
        }
    });
}
function login_sucessfull(url_to_goto, show_main_menu) {

    show_main_menu = typeof (show_main_menu) == "undefined" ? true : show_main_menu

    allow_login_check = false;

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



    updateCsrfToken();
    updateFooterDiv();
    updateSecurityDiv();
    update_content();
    call_login_callbacks();
    set_my_timezone();

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

    logedIn();
    stop_animation();

    allow_login_check_timer = setTimeout("allow_login_check=true;", 10000);
    // check_login_status();

    renderFavoriteDiv();

    if (show_main_menu) {
        updateAppDiv();
    }

}
function logedIn() {



    var body_width = $(document).width();
    var body_height = $(document).height();


    var grid_width = 1300 //parseInt($("div.grid_tabnav").css("width")); 
    var grid_height = 900; //parseInt($("div.grid_tabnav").css("height"));


    console.log('body_width', body_width);
    console.log('body_height', body_height);
    console.log('grid_width', grid_width);
    console.log('grid_height', grid_height);



    if (body_width > grid_width) {
        var site_left = "100px"
        var cloud_left = (body_width - 500) + 'px'
    } else
    {
        var site_left = "100px"
        var cloud_left = (grid_width - 400) + 'px'

    }

    if (body_height > grid_height) {
        var site_top = "25px"
        var cloud_top = (body_height - 125) + 'px'

    } else
    {
        var site_top = "25px"
        var cloud_top = (grid_height) + 'px'

    }


    console.log('site_left', site_left);
    console.log('cloud_left', cloud_left);
    console.log('site_top', site_top);
    console.log('cloud_top', cloud_top);


    $("#site-logo").animate({
        top: site_top,
        left: site_left
    }, {
        queue: false,
        duration: 1000,
        easing: 'easeOutBounce'
    });


    $("#cloud-logo").animate({
        top: cloud_top,
        left: cloud_left
    }, {
        queue: false,
        duration: 1000,
        easing: 'easeOutBounce'
    });

    updateFooterDiv();

    if (allow_login_check) {
        updateAppDiv();

        check_login_status();
    }
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

    renderPartial("login_div.html", "", function (data) {

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
    });

}

function updateFooterDiv()
{
    if ($("#footer").length > 0) {
        renderPartial("footer.html", "#footer", function (data) {
            bindMyAccountClick();
            bindCloseIframe();
        });
    }
}
;

resultData = "";

function updateAppDiv() {
// check and make sure that we are not using the CMS_dialog!
    if ($("div#layout-name").text() != "cms_dialog") {
        renderPartial("cms_interface/grid_tab_nav.html", "#nav-grid-links", function (data) {
            resultData = data;
            if ($("#nav-grid-links").length === 0) {
                var gridContainer = "<div style='display:none;' id='nav-grid-links'></div>";
                $("body").prepend($(gridContainer));
                var gridOverlay = "<div style='display:none;' id='nav-grid-overlay'></div>";
                $("body").prepend($(gridOverlay));
                $("html, body").animate({scrollTop: 0}, "slow");
            }

            $("#nav-grid-links").html(data);
            $(".grid_tabnav ul li").removeClass("hidden");
            // $("#grid-nav").fadeIn();
            if (window.matchMedia("only screen and (max-width: 524px)").matches)
            {
                $("#nav-grid-links").fadeIn();
                $("#nav-grid-overlay").fadeIn();
                $("#grid-nav").css("top", "0px");
            } else
            {
                $("#nav-grid-links").fadeIn();
                $("#nav-grid-overlay").fadeIn();
                $("#grid-nav").css("top", "0px");
            }

            bindAppClick();
            bindCloseGrid();
            bindFavoriteClick();
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
        $("#nav-grid-overlay").fadeOut();
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
        CloseIframe();
    });
}

function CloseIframe(before_clear_callback) {
    $("#nav-grid-links").fadeIn();
    $("#nav-grid-overlay").fadeIn();
    $("#application-space").addClass("hidden");
    $($currentApplicationId).removeClass("blowup");
    $(".grid_tabnav ul li").removeClass("hidden");
    $(".grid_tabnav ul li").removeClass("blowup");
    $("#cloud-switch").fadeOut(1000);
    $("#cloud-shortcuts").fadeOut(1000);

    if (typeof (before_clear_callback) == 'function')
    {
        before_clear_callback();

    } else {
        $("div#application-space").html(""); //clear application space div.
    }
    clear_user_locks();
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

function renderFavoriteDiv() {
    renderPartial("/cms_interface/shortcut_grid_nav.html", "div#cloud-shortcuts", function (evt) {
        bindAppClick();
    });
}

function updateFavorite(shortcut) {
    $.ajax({
        url: '/site/update_menu_shortcuts',
        type: 'post',
        data: {shortcut: shortcut},
        dataType: 'json',
        complete: function (request) {
            renderFavoriteDiv();
        }
    });
}

function bindFavoriteClick() {
    $("div.favorite").off("click").on("click", function (evnt) {
        evnt.preventDefault();
        evnt.stopPropagation();
        if ($(this).find("img.favorite-image")[0].src.includes("filled")) {
            $(this).find("img.favorite-image")[0].src = $("img#star-empty")[0].src
        } else
        {
            $(this).find("img.favorite-image")[0].src = $("img#star-filled")[0].src
        }
        var shortcut = $(this).parent().parent().attr("id");

        updateFavorite(shortcut)

    })
}


function bindIconButtonClick() {
    $('.icon-button').click(function (e) {
        bypassMobilVerticalAdjust = $("div#vertical-adjust-bypass").text().trim();
        if ((window.matchMedia("only screen and (max-width: 524px)").matches) | (isMobile)) {
            the_url = $(this).attr("href").replace("window", "screen");
            $(this).attr("href", the_url);
            // the_url = $(this).attr("href");
            console.log(the_url);

            e.stopPropagation();
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
        $("#nav-grid-overlay").fadeOut();
        //$("#grid-nav").fadeOut();

        require("jquery.urlparser.js");
        var windowType = $.url(this.href).param("window_type");
        var theController = $.url(this.href).segment(1);
        var theAction = $.url(this.href).segment(2) || "index"



        if (windowType == "iframe") {
//   alert("This is an iframe app.");

            var thisApp = createiFrameOverlay(theController, data, this.href);
            $("#cloud-switch").fadeIn(1000);
            $("#cloud-shortcuts").fadeIn(1000);

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
                        $("#nav-grid-overlay").fadeIn();
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

                requireCss(theController + "/" + theAction + "_override.css");
                require(theController + "/" + theAction + "_override.js");
                //// console.log(theController + "_" + theAction + "_callDocumentReady");

                try
                {
                    if ((typeof (theController + "_" + theAction + "_callDocumentReady") == 'function') | (typeof (eval(theController + "_" + theAction + "_callDocumentReady")) == 'function')) {
                        eval(theController + "_" + theAction + "_callDocumentReady()");
                    }
                } catch (e) {
// statements to handle any exceptions
                    console.log(e); // pass exception object to error handler
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

function bindLoginTwoFactorLink() {
    $('.two-factor-link').click(function (e) {

        var formContainer = $('div.login-form');
        // Flipping the forms
        formContainer.toggleClass('flipped-two-factor');
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

function requestedLoginBox() {
    var login_requested = $("div#login").text();
    var url_requested = $("div#url").text();
    if (login_requested == "true") {
        loadLoginBox(url_requested);
    }
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

function update_backoffice_elements() {

    $("div.back-office-refresh-element").each(function (index) {
        var function_to_call = $(this).attr("data-update");
        if (typeof eval(function_to_call) == "function") {
            eval(function_to_call + "()");
        }
    });
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
                location = "/";
                break;
            }
            case 0: // false and not able to continue 
            {
                setUpPurrNotifier("Notice", data.message);
                toggle_reset_box(false);
                location = "/";
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
        success: function (data, status, jqXHR)
        {
            //         console.log(data);
            //         console.log(status);
            //         console.log(jqXHR);
            if (jqXHR.status == 203)
            {
                setUpPurrNotifier("Notice", data);
                setTimeout(function () {
                    location = "/";
                    ;
                }, 5000);
            } else
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
        location = "/";
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
// hide login box if visible

                toggle_login_box();
                loadResetBox(param);
                ///         console.log("found admin action!");
                break;
            }
            default:
            {
// do nothing
            }
        }

    }
}

//
// function to allow field specific searching within datatables.
//
//
function bindDatatableSearchField(search_field_name, model_name) {
    $(search_field_name).attr("title", "Use ':' to search specific fields. Seperate search terms by ','..  Use a '!' to search for empty fields. Use a '%' as first character in search to find string anywhere in field (vs. start of field).")

    $(search_field_name).autocomplete({
//     source: "/contacts/contact_search.json",
        source: function (request, response) {
            var field_value = request.term;
            if ((field_value == ":") | (field_value.slice(-2) == ",:") | (field_value.slice(-3) == ", :")) {
                //           console.log("activate popup.");
                // $("div.dataTables_filter input").css("width", "400px");
                $(search_field_name).autoGrowInput({minWidth: 135, maxWidth: 400, comfortZone: 50});
                $(search_field_name).css("min-width", "200px");
                $.ajax({
                    url: "/" + model_name + "/search_fields.json",
                    dataType: "json",
                    data: {
                        q: request.term,
                    },
                    success: function (data) {

                        // Handle 'no match' indicated by [ "" ] response
                        response(data.length === 1 && data[ 0 ].length === 0 ? [] : data);
                    }

                });
            }
        }
        , minLength: 0
        , focus: function (event, ui) {

            return false;
        }
        , select: function (event, ui) {


            var current_value = $(this).val();
            var field_value = "";
            if (current_value == ":") // first search term.
            {
                field_value = ui.item.value + ":";
            } else
            {
                field_value = (current_value.slice(-2) == ",:" ? current_value.slice(0, -2) : (current_value.slice(-3) == ", :" ? current_value.slice(0, -3) : current_value));
                field_value = field_value + ", " + ui.item.value + ":";
            }

            $(this).val(field_value);
            $(this).caretToEnd().autoGrowInput();
            return false;
        }
    }
    );
}

// Utility to build a usable QR image src from raw AuthPoint 'command' or QR payload
// If the string is already a URL or data URI, use it; otherwise generate a QR on the fly via a public QR service.
function computeAuthPointQrSrc(raw) {
  try {
    if (!raw) { return ''; }
    var s = String(raw);
    // Already a data URL or URL/path? just return it
    if (/^(data:image\/.+;base64,)/i.test(s) || /^(https?:)?\/\//i.test(s) || s.charAt(0) === '/') {
      return s;
    }
    // Otherwise, treat as payload that must be rendered into a QR image
    var payload = encodeURIComponent(s);
    // Use a reliable public QR code image generator
    return 'https://api.qrserver.com/v1/create-qr-code/?size=240x240&data=' + payload;
  } catch(e) {
    return '';
  }
}
