/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

// TODO:  Add ajax function to load pictures based on properties object.

$(window).scroll(function () { 
    if ($(window).scrollTop() > $('body').height() / 2) {
        $("div#page-scrollback-image").fadeIn();
    }
    else
    {
        $("div#page-scrollback-image").fadeOut();

    } 
});

$(document).load(function(){
     if ($("#slider-nav").text() == "false"){
         $("a.slidesjs-navigation").hide();
         console.log("slider nav hidden.");
        };
        
});



$(document).ready(function(){
        setupPagePopup();

    // update left to correct height.
    $("#page-middle-left").height($("#page-body").height() + parseInt($("#page-body").css("margin-top")))


    // check for full screen and adjust layout
    if ($("#full-screen").html() == "true")
    {
        $("div#page-middle-left").hide();
        $("div#content").width("100%");
        $('#Content').css('background',"white")

    }
    //    $('#slides').slides({
    //        preload: true,
    //        preloadImage: '/images/interface/loading.gif',
    //        play: 5000,
    //        effect: 'fade',
    //        crossfade: true,
    //        hoverPause: false,
    //        next: 'next-slide',
    //        prev: 'prev-slide'
    //
    //
    //    });	
activate_slides();
//    slideshow_width =  parseInt($("#slider-width").text());
//    slideshow_height=  parseInt($("#slider-height").text());
//    slideshow_nav_pagination = $("#slider-nav").text();
//    slideshow_effect = $("#slider-effect").text();
//        
//    $('#slides3').slidesjs({
//        width: slideshow_width,
//        height: slideshow_height,
//        pagination: {   
//            active: slideshow_nav_pagination,
//            // [boolean] Create pagination items.
//            // You cannot use your own pagination. Sorry.
//            effect: slideshow_effect
//        // [string] Can be either "slide" or "fade".
//        },
//        play: {
//            //active: false       ,
//            // [boolean] Generate the play and stop buttons.
//            // You cannot use your own buttons. Sorry.
//            effect: "fade",
//           
//            // [string] Can be either "slide" or "fade".
//            //interval: 5000,
//            // [number] Time spent on each slide in milliseconds.
//            auto: true,
//            // [boolean] Start playing the slideshow on load.
//            //swap: true,
//            // [boolean] show/hide stop and play buttons
//            pauseOnHover: true,
//        // [boolean] pause a playing slideshow on hover
//        //    restartDelay: 2500
//        // [number] restart delay on inactive slideshow
//        },
//        navigation: {
//            active: slideshow_nav_pagination,
//            // [boolean] Generates next and previous buttons.
//            // You can set to false and use your own buttons.
//            // User defined buttons must have the following:
//            // previous button: class="slidesjs-previous slidesjs-navigation"
//            // next button: class="slidesjs-n           ext slidesjs-navigation"
//            effect: "fade"
//        // [string] Can be either "slide" or "fade".
//        },
//    
//    });	
// 
//    //       paginationClass: 'slide-pagination'
//                 
//    // resize the slider area and adjust the position of the prev next buttons.
//    
//    if (( $("div#slides3 div.slidesjs-container").length > 0 ))
//    {  
//       
//        
//        if ($("#slider-nav").text() == "false"){
//         $("a.slidesjs-navigation").hide();
//        };
//
//        $("div#slides3 .slidesjs-container").width($("#slider-width").text());
//        $("div#slides3 .slidesjs-container").height($("#slider-height").text());
//        $("div#slides3 .slidesjs-container div.slides_control").width($("#slider-width").text());
//        $("div#slides3 .slidesjs-container div.slides_control").height($("#slider-height").text());
//        $("div#slides3 .slidesjs-container div.slider-content").width($("#slider-width").text());
//        $("div#slides3 .slidesjs-container div.slider-content").height($("#slider-height").text());
//    
//        //  slideshow_width = $("#slides").width();
//        //  slideshow_height =$("#slides").height();
//    
//        slideshow_width =  parseInt($("#slider-width").text());
//        slideshow_height=  parseInt($("#slider-height").text());
//    
//        slideshow_offset = $("#slides3").offset();
//        slideshow_middle = (slideshow_height / 2) - ($("#slides3 .next-slide").height() / 2);
//  
//        $("#slides3 a.slidesjs-next").offset({
//            top: slideshow_middle + slideshow_offset.top, 
//            left: slideshow_width + slideshow_offset.left + 17 
//        });
//        
//        $("#slides3 a.slidesjs-previous").offset({
//            top: slideshow_middle + slideshow_offset.top, 
//            left: slideshow_offset.left - $("#slides3 .prev-slide").width() - 30
//        });
//
//        $("#slides3").css("overflow","visible");
//
//        $("#page-slider-gallary-page").css("position","absolute");
//
//        $("#page-slider-gallary-page").show();
//    }
//    else
//    {
//        $("#page-slider-gallary-page").hide();
//
//    }
 
});


function activate_slides() {

    if (($("div#slides3").length > 0))
    {
        $("#page-slider-gallary-page").show();
    }
    else
    {
        $("#page-slider-gallary-page").hide();

    }

    console.log($("div#slides3 > div").length);

    if ($("div#slides3 > div").length > 1)
    {
        slideshow_width = parseInt($("#slider-width").text());
        slideshow_height = parseInt($("#slider-height").text());
        slideshow_nav_pagination = $("#slider-nav").text();
        slideshow_effect = $("#slider-effect").text();
        slideshow_auto = $("#slider-auto").text() || "true"
        slideshow_speed = $("#slider-speed").text() || "5000"



        $('#slides3').slidesjs({
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
                interval: 5000,
                // [number] Time spent on each slide in milliseconds.
                auto: false,
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


        if (($("div#slides3 div.slidesjs-container").length > 0))
        {


            if ($("#slider-nav").text() == "false") {
                $("a.slidesjs-navigation").hide();
            }
            ;

            $("div#slides3 .slidesjs-container").width($("#slider-width").text());
            $("div#slides3 .slidesjs-container").height($("#slider-height").text());
            $("div#slides3 .slidesjs-container div.slides_control").width($("#slider-width").text());
            $("div#slides3 .slidesjs-container div.slides_control").height($("#slider-height").text());
            $("div#slides3 .slidesjs-container div.slider-content").width($("#slider-width").text());
            $("div#slides3 .slidesjs-container div.slider-content").height($("#slider-height").text());

            //  slideshow_width = $("#slides").width();
            //  slideshow_height =$("#slides").height();

            slideshow_width = parseInt($("#slider-width").text());
            slideshow_height = parseInt($("#slider-height").text());

            slideshow_offset = $("#slides3").offset();
            slideshow_middle = (slideshow_height / 2) - ($("#slides3 .next-slide").height() / 2);

            $("#slides3 a.slidesjs-next").offset({
                top: slideshow_middle + slideshow_offset.top,
                left: slideshow_width + slideshow_offset.left + 17
            });

            $("#slides3 a.slidesjs-previous").offset({
                top: slideshow_middle + slideshow_offset.top,
                left: slideshow_offset.left - $("#slides3 .prev-slide").width() - 30
            });

            $("#slides3").css("overflow", "visible");

        }
    $("#page-slider-gallary-page").css("position", "absolute");

    }
    else
    {
        $("#page-slider-gallary-page").css("top", "0px");
        $("#page-slider-gallary-page").css("overflow", "hidden");

    }

}

function setupPagePopup() {
    $.each($('.page-popup-link'),function(){
        var  page_to_open = $(this).attr('href');
        $(this).attr('href','#');
        $(this).attr('onClick','return(0);');
        $(this).attr("page-to-open",page_to_open);
    // console.log(this);
    });
      
    $('.page-popup-link').click( function(){
        var  page_to_open = $(this).attr('page-to-open');
        var  page_name = $(this).attr('title') || "popup-page";

        $.ajax({
            url: page_to_open, 
            success: function(data) 
            {
                pageViewDialog = createAppDialog(page_name,data);
                $("div.ui-dialog-titlebar").hide();
                $("div.ui-dialog .ui-dialog-buttonpane").css("border-width","0px");
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
                    close: function( event, ui ) {
                        $('#app-dialog').html("");
                        $('#app-dialog').dialog( "destroy" );
                    }
                });
            // require("roles/update_rights.js");
            // update_rights_callDocumentReady();


            // setupRolesSelection();
            }
        });
    });
}

// ************************************    
//
// Create Edit Dialog Box
//
// ************************************    

function createAppDialog(theName, theContent) {
    
    console.log(theName);
    
    if ($("#app-dialog-" + theName).length == 0) 
    {    
        var dialogContainer =  "<div id='app-dialog-" + theName + "'></div>";
        $("#page").append($(dialogContainer));
    }
    else 
    {
        dialogContainer=$("#app-dialog-" + theName);   
    }
    // $('#app-dialog').html(theContent);
    theContent = '<input type="hidden" autofocus="autofocus" />' + theContent
    theAppDialog =  $("#app-dialog-" + theName).dialog({
        autoOpen: false,
        modal: true,
        buttons: {
            "Close": function() { 
                // Do what needs to be done to complete 
                $(this).dialog("close"); 
            }
        },
        close: function( event, ui ) {
            $('#app-dialog-' + theName).html("");
            $('#app-dialog-' + theName).dialog( "destroy" );
        },
        open: function (event, ui)
        {
            popUpAlertifExists();
        }
        
        
    });
    
    $('#app-dialog-' + theName).html(theContent);

    theHeight= $('#app-dialog-' + theName+ ' #dialog-height').text() || "500";
    theWidth= $('#app-dialog-' + theName+ ' #dialog-width').text()  || "500";
    theTitle= $('#app-dialog-' + theName+ ' #dialog-name').text() || "Edit";
    
    theAppDialog.dialog({
        title:theTitle,
        width: theWidth,
        height:theHeight
    });
        
    return(theAppDialog)
}
