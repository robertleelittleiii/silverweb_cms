/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

// TODO:  Add ajax function to load pictures based on properties object.

$(window).scroll(function () {
    if ($(window).scrollTop() > $('body').height() / 2) {
        $("div#page-scrollback-image").fadeIn();
    } else
    {
        $("div#page-scrollback-image").fadeOut();

    }
});

$(document).load(function () {
    if ($("#slider-nav").text() == "false") {
        $("a.slidesjs-navigation").hide();
        console.log("slider nav hidden.");
    }
    ;

});


$(document).ready(function () {
    call_document_ready_on_show_page();
});


function call_document_ready_on_show_page() {
    setupPagePopup();

    // update left to correct height.
    $("#page-middle-left").height($("#page-body").height() + parseInt($("#page-body").css("margin-top")))


    // check for full screen and adjust layout
    if ($("#full-screen").html() == "true")
    {
        $("div#page-middle-left").hide();
        $("div#content").width("100%");
        $('#Content').css('background', "white")

    }

    activate_slides();
        start_flex_sliders();

    require("pages/shared.js");
    pageeditClickBinding("div#edit-pages");

    setupPagePopup();

// check to see if we need to pop up a window

    if ($("#pop-up-page-link").text() != "")
    {
        showPagePopup($("#pop-up-page-link").text());

    }

    enablePageEdit();
    enableSliderEdit();
    requestedLoginBox();

}

function start_flex_sliders() {
    slideshow_nav_pagination = $("#slider-nav").text() === "true";
    slideshow_effect = $("#slider-effect").text();
    slideshow_auto = $("#slider-auto").text() == "true" ? true : false
    slideshow_speed = $("#play-speed").text() || "5000"

    slideshow_itemswidth = $("#slider-width").text() || "210"
    carousel_itemswidth = $("#carousel-items-width").text() || "210"



    if ($('.flexslider.carousel').length > 0) {
        require("jquery.flexslider.js");
        // page-slider-gallary-page$('#page-slider-gallary-page').fadeIn();

        $('.flexslider.carousel').flexslider({
            animation: "slide",
            animationLoop: false,
            itemWidth: Number(carousel_itemswidth),
            itemMargin: 10
        });

        // $('.flexslider.carousel').flexslider({start: function () {
        //         $('#page-slider-gallary-page').fadeIn();
        //     }, animation: slideshow_effect, animationLoop: false, itemWidth: slideshow_itemswidth, itemMargin: 5});

    } else if ($('.flexslider').length > 0) {
        require("jquery.flexslider.js");
        $('.flexslider').flexslider({start: function () {
                $('#page-slider-gallary-page').fadeIn();
            }, slideshow: slideshow_auto, animation: slideshow_effect, directionNav: slideshow_nav_pagination, animationSpeed: 2000, slideshowSpeed: slideshow_speed});

    }



}

function activate_slides() {

    if (($("div.slides3").length > 0))
    {
        $("#page-slider-gallary-page").show();
    } else
    {
        //    $("#page-slider-gallary-page").hide();

    }

    console.log($("div.slides3 > div").length);

        if ($("div.slides3 > div").length > 1)
    {
        slideshow_width = parseInt($("#slides3-slider-width").text());
        slideshow_height = parseInt($("#slides3-slider-height").text());
        slideshow_nav_pagination = $("#slides3-slider-nav").text();
        slideshow_effect = $("#slides3-slider-effect").text();
        slideshow_auto = $("#slides3-slider-auto").text() || "true"
        slideshow_speed = $("#slides3-slider-speed").text() || "5000"



        $('div.slides3').slidesjs({
            width: slideshow_width,
            height: slideshow_height,
            pagination: {
                active: true,
                // [boolean] Create pagination items.
                // You cannot use your own pagination. Sorry.
                effect: slideshow_effect
                        // [string] Can be either "slide" or "fade".
            },
            play: {
                active: false,
                // [boolean] Generate the play and stop buttons.
                // You cannot use your own buttons. Sorry.
                effect: slideshow_effect,
                // [string] Can be either "slide" or "fade".
                interval: slideshow_speed,
                // [number] Time spent on each slide in milliseconds.
                auto: slideshow_auto,
                // [boolean] Start playing the slideshow on load.
                //swap: true,
                // [boolean] show/hide stop and play buttons
                pauseOnHover: true,
                // [boolean] pause a playing slideshow on hover
                //    restartDelay: 2500
                // [number] restart delay on inactive slideshow
            },
            navigation: {
                active: slideshow_nav_pagination,
                // [boolean] Generates next and previous buttons.
                // You can set to false and use your own buttons.
                // User defined buttons must have the following:
                // previous button: class="slidesjs-previous slidesjs-navigation"
                // next button: class="slidesjs-n           ext slidesjs-navigation"
                effect: slideshow_effect
                        // [string] Can be either "slide" or "fade".
            }

        });


        if (($("div.slides3 div.slidesjs-container").length > 0))
        {


            if ($("#slider-nav").text() == "false") {
                $("a.slidesjs-navigation").hide();
            }
            ;

            $("div.slides3 .slidesjs-container").width(slideshow_width);
            $("div.slides3 .slidesjs-container").height(slideshow_height);
            $("div.slides3 .slidesjs-container div.slides_control").width(slideshow_width);
            $("div.slides3 .slidesjs-container div.slides_control").height(slideshow_height);
            $("div.slides3 .slidesjs-container div.slider-content").width(slideshow_width);
            $("div.slides3 .slidesjs-container div.slider-content").height(slideshow_height);

            //  slideshow_width = $("#slides").width();
            //  slideshow_height =$("#slides").height();

            slideshow_width = parseInt($("#slider-width").text());
            slideshow_height = parseInt($("#slider-height").text());

            slideshow_offset = $("div.slides3").offset();
            slideshow_middle = (slideshow_height / 2) - ($("div.slides3 .next-slide").height() / 2);

            $("div.slides3 a.slidesjs-next").offset({
                top: slideshow_middle + slideshow_offset.top,
                left: slideshow_width + slideshow_offset.left + 17
            });

            $("div.slides3 a.slidesjs-previous").offset({
                top: slideshow_middle + slideshow_offset.top,
                left: slideshow_offset.left - $("div.slides3 .prev-slide").width() - 30
            });

            $("div.slides3").css("overflow", "visible");

        }
        $("#page-slider-gallary-page").css("position", "absolute");

    } else
    {
        $("#page-slider-gallary-page").css("top", "0px");
        $("#page-slider-gallary-page").css("overflow", "hidden");

    }

}

function showPagePopup(page_to_open) {

    var page_name = "popup-page";

    $.ajax({
        url: page_to_open,
        success: function (data)
        {
            pageViewDialog = createAppDialog(page_name, data);
            $("div.ui-dialog-titlebar").hide();
            $("div.ui-dialog .ui-dialog-buttonpane").css("border-width", "0px");
            $(".ui-dialog .ui-dialog-buttonpane button span").html("X");

            dialogHeight = $(".ui-dialog").height();
            dialogWidth = $(".ui-dialog").width();
            $(".ui-dialog").css("background", "none");
            $(".ui-dialog").css("border", "none");

            $(".ui-dialog .ui-dialog-buttonpane").css("background", "none");

            $(".ui-dialog .ui-dialog-buttonpane button").css("position", "absolute");
            $(".ui-dialog .ui-dialog-buttonpane button").css("top", "40px");
            $(".ui-dialog .ui-dialog-buttonpane button").css("right", "40px");
            $(".ui-dialog .ui-resizable-se").css("display", "none");

            pageViewDialog.dialog('open');
            pageViewDialog.dialog({
                close: function (event, ui) {
                    $('#app-dialog').html("");
                    $('#app-dialog').dialog("destroy");
                }
            });
            // require("roles/update_rights.js");
            // update_rights_callDocumentReady();


            // setupRolesSelection();
        }
    });

}

function setupPagePopup() {
    $.each($('.page-popup-link'), function () {
        var page_to_open = $(this).attr('href');
        $(this).attr('href', '#');
        $(this).attr('onClick', 'return(0);');
        $(this).attr("page-to-open", page_to_open);
        // console.log(this);
    });

    $('.page-popup-link').click(function () {
        var page_to_open = $(this).attr('page-to-open');
        var page_name = $(this).attr('title') || "popup-page";

        $.ajax({
            url: page_to_open,
            success: function (data)
            {
                pageViewDialog = createAppDialog(page_name, data);
                $("div.ui-dialog-titlebar").hide();
                $("div.ui-dialog .ui-dialog-buttonpane").css("border-width", "0px");
                $(".ui-dialog .ui-dialog-buttonpane button span").html("X");

                dialogHeight = $(".ui-dialog").height();
                dialogWidth = $(".ui-dialog").width();
                $(".ui-dialog").css("background", "none");
                $(".ui-dialog").css("border", "none");

                $(".ui-dialog .ui-dialog-buttonpane").css("background", "none");

                $(".ui-dialog .ui-dialog-buttonpane button").css("position", "absolute");
                $(".ui-dialog .ui-dialog-buttonpane button").css("top", "40px");
                $(".ui-dialog .ui-dialog-buttonpane button").css("right", "40px");
                $(".ui-dialog .ui-resizable-se").css("display", "none");

                pageViewDialog.dialog('open');
                pageViewDialog.dialog({
                    close: function (event, ui) {
                        $('#app-dialog').html("");
                        $('#app-dialog').dialog("destroy");
                    }
                });
                // require("roles/update_rights.js");
                // update_rights_callDocumentReady();


                // setupRolesSelection();
            }
        });
    });
}

