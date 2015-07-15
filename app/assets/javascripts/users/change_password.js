/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


function setupPasswordValidation() {

    $("#user_password").validate({
        expression: "if (VAL.length > 5 && VAL) return true; else return false;",
        message: "Please enter a valid Password"
    });
    $("#user_password_confirmation").validate({
        expression: "if ((VAL == $('#user_password').val()) && VAL) return true; else return false;",
        message: "Confirm password field doesn't match the password field"
    });
}

function bindChangePasswordClick(callbackFunction) {
    $('#update-password-form').unbind('ajax:success');
    $('#update-password-form').bind('ajax:beforeSend', function (evt, xhr, settings) {
        // alert("ajax:before");  
        console.log('ajax:before');
        console.log(evt);
        console.log(xhr);
        console.log(settings);


    }).bind('ajax:success', function (evt, data, status, xhr) {
        //  alert("ajax:success"); 
        console.log('ajax:success');
        console.log(evt);
        console.log("date:" + data + ":");
        if (data.complete) {
            setUpPurrNotifier("Notice", "Password was changed sucessfully.");
        }
        else
        {
            setUpPurrNotifier("Warning", "Password was not changed due to an error.");
        }

        if (typeof callbackFunction == 'function')
        {
            callbackFunction();
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
        setUpPurrNotifier("Warning", "Password was not changed due to an error.");


    }).bind('ajax:complete', function (evt, xhr, status) {
        //    alert("ajax:complete");  
        console.log('ajax:complete');
        console.log(evt);
        console.log(xhr);
        // console.log(status);


    });

}
function change_password_callDocumentReady()
{
    require("jquery.validate.js");
    //   requireCss("m-scaffold.css");
    requireCss("jquery.validate.css");
    requireCss("users/change_password.css");
    console.log("called change password doc ready.")
    setupPasswordValidation();
    //bindChangePasswordClick();
    $("input.button-link").button();
}

$(document).ready(function () {
    if ($("#as_window").text() == "true")
    {
        //  alert("it is a window");
    }
    else
    {
        //   change_password_callDocumentReady();
    }
});