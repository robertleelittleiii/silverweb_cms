/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

function activate_scroller_sort () {
    
    $('#sliders').sortable({
        axis: 'y',
        dropOnEmpty: false,
        handle: '.slider-drag',
        cursor: 'crosshair',
        items: 'li',
        opacity: 0.4,
        scroll: true,
        update: function(){
            page_id = $("#page-id").html().trim();

            $.ajax({
                type: 'post',
                data: $('#sliders').sortable('serialize') + "&page_id=" + page_id ,
                dataType: 'script',
                complete: function(request){
                    $('#sliders').effect('highlight');
                },
                url: '/sliders/sort'
            })
        }
    });    
}

function set_up_add_slider_callback() {
    
    $("#add-slider")
    .bind("ajax:success", function(event, data, status, xhr) {
        page_id = $("#page-id").html().trim();
        $.ajax({
            type: 'POST',
            data: 'page_id='+page_id ,
            dataType: 'html',
            success: function(data){
                $('ul#sliders').html(data);
                activate_scroller_sort();
                set_up_delete_slider_callback();
    $('iframe.preview').attr("src", $('iframe.preview').attr("src"));

                
            },
            url: '/pages/get_sliders_list'
        })
    });
}

function set_up_delete_slider_callback() {
    
    $(".delete_slider")
    .bind("ajax:success", function(event, data, status, xhr) {
        page_id = $("#page-id").html().trim();
        $.ajax({
            type: 'POST',
            data: 'page_id='+page_id ,
            dataType: 'html',
            success: function(data){
                $('ul#sliders').html(data);
                activate_scroller_sort();
                set_up_delete_slider_callback();
                    $('iframe.preview').attr("src", $('iframe.preview').attr("src"));

            },
            url: '/pages/get_sliders_list'
        })
    });
    
}

function loadCustomCSS() {
    
    var custom_css = $("#best_in_place_page_template_name").text();
    requireCss("site/show_page-" + custom_css + ".css");
}

// triggered when the save button is clicked in tinemce.

function mysave() {
    console.log("trigger save");
    tinymce.triggerSave();
    // $("#page-body-save").closest("form").trigger("submit");
    $("#page_body").parent().parent().closest("form").trigger("submit");

[]
}

$(document).ready(function(){

    loadCustomCSS();
    activate_scroller_sort();
    set_up_delete_slider_callback();
    set_up_add_slider_callback();

    setupCheckboxes(".security-check");

    $('#page_body_save').bind("click", function() {
        alert("clicked");
        $(this).closest("form").trigger("submit");
        return true;
    });
    
});

function ajaxSave()
{
    
    tinyMCE.triggerSave();

    $("#page_body_save").closest("form").trigger("submit");
    
    
}

function BestInPlaceCallBack(input) {
    
    $('iframe.preview').attr("src", $('iframe.preview').attr("src"));
    loadCustomCSS();
}
