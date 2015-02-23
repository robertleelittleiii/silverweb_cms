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

    for(var i=0; i<props.length; i++){
        if(props[i] in testDom.style){
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
        document.cookie="testcookie";
        cookieEnabled = (document.cookie.indexOf("testcookie") != -1) ? true : false;
    }
        
    return (cookieEnabled);
}

//
//
// code to check for mobile device
//
//


function customizeForDevice(){
    var ua = navigator.userAgent;
    var checker = {
        iphone: ua.match(/(iPhone|iPod|iPad)/),
        ipad: ua.match(/(iPad)/),
        blackberry: ua.match(/BlackBerry/),
        android: ua.match(/Android/),
        palm: ua.match(/Palm/)
    };
    if (checker.android){
        return("mobile:android");
    // $('.android-only').show();
    }
    else if (checker.iPad){
        return("mobile:ipad");

    //  $('.idevice-only').show();
    }
    else if (checker.iphone){
        return("mobile:iphone");

    //  $('.idevice-only').show();
    }
    else if (checker.blackberry){
        return("mobile:blackberry");

    //  $('.berry-only').show();
    }
    else if (checker.palm){
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
    b=1;
    for (x=0;x < a.length; x++) {
        if (a[x].length >= t.cols) b+= Math.floor(a[x].length/t.cols);
    }
    b+= a.length;
    if (b > t.rows) t.rows = b;
}


//
// javascript loader asycn using ajax
//
//
function require(script) {
    var theUrl="/javascripts/"+script;
    var theTimeStamp = getRailsTimeStamp();
    
    // $("script[src='/javascripts/ie_fixes.js?1361329086']")
    
    if (!$("script[src^='" + theUrl + "']").length) {
        // alert("loaded");
        $.ajax({
            url: theUrl + "?"+ theTimeStamp,
            dataType: "script",
            async: false,           // <-- this is the key
            success: function () {
                var javascriptLink = $("<script>").attr({
                    type: "text/javascript",
                    src: theUrl + "?"+ theTimeStamp 
                }); 
                $("head").append(javascriptLink);

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
    var href = "/stylesheets/"+cssFile

    if (!$("link[href^='" + href +"']").length) {
        //alert("loaded");
        $.ajax({
            url: href+"?"+theTimeStamp,
            dataType: 'text',
            success: function(){
                var cssLink = $("<link>").attr({
                    rel:  "stylesheet",
                    type: "text/css",
                    href: href+"?"+theTimeStamp
                }); 
                $("head").append(cssLink);
          
            //your callback
            },
            fail: function(){
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
    var message= $("#alert").text().trim();

    setUpPurrNotifier("Alert", message);
   
    var message= $("#notice").text().trim();

    setUpPurrNotifier("Alert", message);

}



function setUpPurrNotifier(headline, message)
{
    var notice = ''
    +'<div id="notify-container" style="display:none">' 
    +   '<div id="notice-body">'
    +       '<a class="ui-notify-close ui-notify-cross" href="#">x</a>'
    +	'<div style="float:left;margin:0 10px 0 0; min-height:50px;">'
    +           '<img src="/assets/interface/info.png" alt="warning">'
    +        '</div>'
    +       '<h1>#{title}</h1>'
    +       '<p>#{text}</p>'
    +	'</div>'
    +'</div>';


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

        $("#notify-container").notify("create","notice-body", {
            title: headline,
            text: message
        });
    }  
}

function disableSelectOptionsSeperators()
{
    found_options = $("select option");

    found_options.each(function() {
        if ($(this).text() == "-") {
            $(this).prop('disabled', true);
        };
    });
}

function createPasswordDialog() {
    
    $('#edit-password-dialog').dialog({
        autoOpen: false,
        width: 706,
        height:245,
        modal:true
    });
}

function setupCheckboxes(inputElement) {
    $(inputElement).click( function() {
        $(this).closest('form').trigger('submit');
    });

}