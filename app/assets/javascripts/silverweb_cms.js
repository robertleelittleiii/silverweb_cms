// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
// require jquery
//= require jquery.turbolinks
//= require jquery-ui
// require jquery_ujs
//= require jquery.autoGrowInput
//= require jquery.caret
//= require jquery.cookie
//= require jquery.notify
//= require jquery.dataTables
//= require jquery-observe_fields
//= require best_in_place
//= require general_utilities
//= require tinymce-jquery
//= reauire /tinymce/themes/modern/theme.js
//= require jquery-fileupload/basic
//= require jquery-fileupload/vendor/tmpl
//= require cloud
//= require superfish

//

$(document).ready(function () {
    popUpAlertifExists();
    updateSearchFormBindings();
    disableSelectOptionsSeperators();
    bindLoginButton();
    bindLogoutClick();
    bindMyAccount();
    $(".best_in_place").best_in_place();

    $(".datepicker").datepicker();

    ui_ajax_select();

    $("a.button-link").button();
    enablePageEdit();
    
    if ($('ul.sf-menu').length > 0)
    {
     $('ul.sf-menu').superfish({
              dropShadows: false                            // enable drop shadows 
             
         }); 
     }
     
     //fix for issue with popup dialog and tinymce
     $(document).on('focusin', function(e) {
    if ($(e.target).closest(".mce-window").length || $(e.target).closest(".moxman-window").length) {
        e.stopImmediatePropagation();
    }
});
});


function enablePageEdit() {
    if ($("#edit-pages").length > 0)
    {
        require("/pages/shared.js")
        pageeditClickBinding("div#edit-pages")
    }
}


function ajaxUpdateSearch(search_term) {

    var form = $("#live-search"); // grab the form wrapping the search bar.
    var url = "/site/live_search"; // live_search action.

    updatePageForSearch();

    if (search_term == null)
    {
        var State = History.getState(); // Note: We are using History.getState() instead of event.state
        window.location.href = State.url;
        //       History.log(State.data, State.title, State.url);
        console.log("search_term == null");
        $("#search-image").removeClass("loading"); // hide the spinner
        return;
    }

    if (queryString("search") == $("#live-search #live-search_search").val().trim())
    {
        console.log("skip update, already loaded");
        $("#search-image").removeClass("loading"); // hide the spinner

        return;
    }

    if (search_term == "")
    {
        var formValue = $("#live-search #live-search_search").val().trim();
        console.log("search_term == ''");
    }

    else
    {
        // $("#live-search #live-search_search").val(search_term);
        var formData = "search=" + search_term;
        var formValue = search_term.trim();
    }

    var full_search_url = url + "?search=" + formValue;

    //  $("#live-search #live-search_search").val(search_term);
    if (($.browser.msie == true))
    {
        window.location.href = "/site/live_search?search=" + formValue;
        $("#search-image").removeClass("loading"); // hide the spinner
    }
    else
    {

        if (/chrome/.test(navigator.userAgent.toLowerCase()))
        {
            window.location.href = "/site/live_search?search=" + formValue;
            $("#search-image").removeClass("loading"); // hide the spinner

        }
        else {
            $.ajax({
                url: full_search_url,
                cache: false,
                success: function (data) {
                    // $("#page-left").hide();
                    $("#search-image").removeClass("loading"); // hide the spinner

                    $("#content").html(data); // replace the "results" div with the results

                    // $("#mainnav").hide();// hide the admin menu
                    $("#live-search_search").focus();
                    $("#live-search_search").caretToEnd();
                    // $("#page-middle-left").fadeOut("10s");
                    location_url = window.location.url;
                    ////console.log(location_url);
                    history_url = "/site/live_search?search=" + formValue;
                    history_url = history_url.replace(/^.*#/, '');
                    ////console.log(history_url);

                    History.pushState('statechange:', "Search for '" + formValue + "'", history_url);
                    // History.log('statechange:', "Search for '"+ formValue +"'", history_url);

                    //  History.pushState("","",history_url) 
                    $("#search-image").removeClass("loading"); // hide the spinner
                    // $("#live-search #live-search_search").val(formValue);

                    // updateSearchFormBindings();
                    bindClickToProductItem();
                    //alert('Load was performed.');
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    document.location.href = full_search_url;
                    return;
                }
            });
        }
        ;
    }
    ;
}

function updateSearchFormBindings() {

    // Executes a callback detecting changes with a frequency of 1 second
    $("#live-search_search").observe_field(1, function () {
        $("#search-image").addClass("loading"); // show the spinner
        //console.log ("observe_field");
        ajaxUpdateSearch("");

    });

    $("#live-search_search").keypress(function (e) {
        if (e.which == 13) {
            ////console.log("keypress- return");
            //           alert("return clicked");
            //jQuery(this).blur();
            //jQuery('#find-treasure').focus().click();
            return false;
        }
    });
}