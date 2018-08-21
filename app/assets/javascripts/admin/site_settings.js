/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */



var toggleLoading = function () {
    $("#loader_progress").toggle()
};
var toggleAddButton = function () {
    $("#upload-form").toggle()
};


function bindCraigsListCheckClick()
{
    $('#craigs-list').click(function () {
        var csrf_token = $('meta[name=csrf-token]').attr('content');
        var csrf_param = $('meta[name=csrf-param]').attr('content');
        var rCraigslistVal = false;

        if ($(this).attr('checked') == "checked")
        {
            var rCraigslistVal = true;
        }

        var request = $.ajax({
            url: "/admin/update_prefs/",
            type: "POST",
            data: {
                site_prefs: {
                    craigs_list: rCraigslistVal
                },
                authenticity_token: csrf_token
            }
        });


        request.done(function (msg) {
            //alert( msg );
        });

        request.fail(function (XHR, textStatus) {
            //the_XHR=XHR;
            //alert( "Request failed: " + textStatus );
        });


    });

}
;


function bindSiteToggleLinkClick()
{
    $('#site-button').click(function () {
        var buttonValue = $("#site-button").html().trim()
        if (buttonValue == "Turn Site ON") {
            $("div#site-status").removeClass("site-down");
            $("div#site-status").addClass("site-up");

            $("#site-button").html("Turn Site OFF");
            $("#site-status").html("Site is UP");
        } else {
            $("div#site-status").removeClass("site-up");
            $("div#site-status").addClass("site-down");

            $("#site-button").html("Turn Site ON");
            $("#site-status").html("Site is DOWN (construction sign in place)");
        }
    });

}
;


function bindImageChage() {

    //
    //
    // image class bindings
    //

    $('input#image').bind("change", function () {
        //alert("changed");
        toggleLoading();
        toggleAddButton();
        $(this).closest("form").trigger("submit");
        $(".imageSingle .best_in_place").best_in_place();

    });

}

function updateBestinplaceImageTitles() {
    $(".imageSingle .best_in_place").best_in_place();

}


$(document).ready(function () {
    bindImageChage();
    bindSiteToggleLinkClick();
    bindCraigsListCheckClick();
    ui_ajax_settings_select();

});