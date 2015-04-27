
var pagetemplateTableAjax = "";
var page_templates_index_callDocumentReady_called = false;

$(document).ready(function () {
    if (!page_templates_index_callDocumentReady_called)
    {
        page_templates_index_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        }
        else
        {
            page_templates_index_callDocumentReady();
        }
    }
});


function page_templates_index_callDocumentReady() {
    requireCss("tables.css");
    require("page_templates/shared.js");

    if ($('#mainnav:visible').length != 0)
    {
        $("div#page-middle-left").hide();
        $("div#content").width("100%");
        $('#Content').css('background', "white")
    }

    //  Required scripts (loaded for this js file)
    //

    // reatePageDialog();
    //    $("body").css("cursor", "progress");[
    //    pageTableOld=$('#page-template-table-old').dataTable({
    //        "aLengthMenu": [[-1, 10, 25, 50], ["All", 10, 25, 50]]
    //    });
    $("body").css("cursor", "progress");

    createPageTemplateTable();

    $("body").css("cursor", "default");

    //
    //    $('#page-template-table .page-template-row').bind('click', function(){
    //        $(this).addClass('row_selected');
    //        pageID=$(this).find("#page-id").text().strip();
    //        window.location = "/page/edit/"+pageID;
    //    });

    //    $('.delete-page-item').bind('ajax:success', function(xhr, data, status){
    //        $("body").css("cursor", "progress");[
    //        theTarget=this.parentNode.parentNode;
    //        var aPos = pagetemplateTableAjax.fnGetPosition( theTarget );
    //        pagetemplateTableAjax.fnDeleteRow(aPos);
    //        pagetemplateTableAjax.fnDraw();
    //        $("body").css("cursor", "default");[]
    //    });

    //    $('.delete-page-item').bind('ajax:error', function(xhr, data, error){
    //        alert("Error:" + JSON.parse(data.responseText)["error"]);
    //        $("body").css("cursor", "default");[]
    //
    //    });

    $(".edit_page_template").bind('ajax:success', function (xhr, data, status) {
        $('#edit-password-dialog').dialog('close');
    });

//    $('a#new-page').unbind().bind('ajax:beforeSend', function (e, xhr, settings) {
//        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
//        $("body").css("cursor", "progress");
//    });
//
//    $('a#new-page').bind('ajax:success', function (xhr, data, status) {
//        $("body").css("cursor", "default");
//        pagetemplateTableAjax.fnDraw();
//        setUpPurrNotifier("Notice", "New Page Created!'");
//    });


    // createPasswordDialog();
    // createPageDialog();
    bindNewPage();
    
    $("a.button-link").button();

}



function deletePage(page_template_id)
{
    var answer = confirm('Are you sure you want to delete this?')
    if (answer) {
        $.ajax({
            url: '/page_templates/delete_ajax?id='+ page_template_id,
            
            success: function (data)
            {
                setUpPurrNotifier("Notice", "Item Successfully Deleted.");
                pagetemplateTableAjax.fnDraw();

            }
        });

    }
}

function editPageTemplate(page_template_id)
{
    var url = '/page_templates/' + page_template_id + '/edit?request_type=window&window_type=iframe';
    $('iframe#page_templates-app-id', window.parent.document).attr("src", url);
}





function loadPageScreen() {

    page - action - area
}


function createPageDialog() {

    $('#edit-page-dialog').dialog({
        autoOpen: false,
        width: 455,
        height: 625,
        modal: true,
        buttons: {
            "Delete": function () {
                page_template_id = $(".m-content div#page-id").text().trim();
                if (confirm("Are you sure you want to delete this page?"))

                {
                    $(this).dialog("close");

                    $.ajax({
                        url: '/page_templates/delete_ajax?id=' + page_template_id,
                        success: function (data)
                        {
                            pagetemplateTableAjax.fnDraw();
                        }
                    });
                }
                else
                {

                }
            },
            "Ok": function () {
                $(this).dialog("close");
                pagetemplateTableAjax.fnDraw();
            }
        }

    });
}



function createPageTemplateTable() {
    console.log("create table");
    pagetemplateTableAjax = $('#page-template-table').dataTable({
        "iDisplayLength": 25,
        "aLengthMenu": [[25, 50, 100], [25, 50, 100]],
        "bStateSave": true,
        "fnStateSave": function (oSettings, oData) {
            localStorage.setItem('DataTables_page_templates_' + window.location.pathname, JSON.stringify(oData));
        },
        "fnStateLoad": function (oSettings) {
            return JSON.parse(localStorage.getItem('DataTables_page_templates_' + window.location.pathname));
        },
        "bProcessing": true,
        "bServerSide": true,
        "aaSorting": [[1, "asc"]],
        "sAjaxSource": "/page_templates/page_template_table",
        "fnRowCallback": function (nRow, aData, iDisplayIndex, iDisplayIndexFull) {
            $(nRow).addClass('page-template-row');
            $(nRow).addClass('gradeA');
            return nRow;
        },
        "fnInitComplete": function () {
            // $(".best_in_place").best_in_place(); 

        },
        "fnDrawCallback": function () {
            $(".best_in_place").best_in_place();
            //pagetemplateeditClickBinding(".edit-page-item");
            pagetemplateeditClickBinding("tr.page-template-row");
            bindDeletePage();
        }
    });
}

function bindNewPage() {
    
   $('a#new-page').unbind().bind('ajax:beforeSend', function (e, xhr, settings) {
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("body").css("cursor", "progress");
    }).bind('ajax:success', function (xhr, data, status) {
        $("body").css("cursor", "default");
        pagetemplateTableAjax.fnDraw();
        setUpPurrNotifier("Notice", "New Page Created!'");
    }).bind('ajax:error', function (evt, xhr, status, error) {
                setUpPurrNotifier("Error", "Page Creation Failed!'");
    }); 

//    $('a#new-page').bind('ajax:beforeSend', function (evt, xhr, settings) {
//        // alert("ajax:before");  
//        console.log('ajax:before');
//        console.log(evt);
//        console.log(xhr);
//        console.log(settings);
//
//        $("body").css("cursor", "progress");
//
//
//
//    }).bind('ajax:success', function (evt, data, status, xhr) {
//        //  alert("ajax:success"); 
//        console.log('ajax:success');
//        console.log(evt);
//        console.log("date:" + data + ":");
//
//        $("body").css("cursor", "progress");
//        console.log(data.id);
//        editPage(data.id);
//
//        console.log(status);
//        console.log(xhr);
//
//    }).bind('ajax:error', function (evt, xhr, status, error) {
//        // alert("ajax:failure"); 
//        console.log('ajax:error');
//        console.log(evt);
//        console.log(xhr);
//        console.log(status);
//        console.log(error);
//
//        alert("Error:" + JSON.parse(data.responseText)["error"]);
//        $("body").css("cursor", "default");
//
//
//    }).bind('ajax:complete', function (evt, xhr, status) {
//        //    alert("ajax:complete");  
//        console.log('ajax:complete');
//        console.log(evt);
//        console.log(xhr);
//        // console.log(status);
//        $("body").css("cursor", "default");
//
//
//    });

}
function bindDeletePage() {
    $(".delete-page-item").on("click", function (e) {

        // console.log($(this).parent().parent().parent().find('#page-id').text());
        var page_template_id = $(this).parent().parent().parent().find('#page-id').text();
        deletePage(page_template_id);
        return false;
    });
}








// ************************************    
//
// Create Edit Dialog Box
//
// ************************************    
//
//function createAppDialog(theContent) {
//    
//        
//    if ($("#app-dialog").length == 0) 
//    {    
//        var dialogContainer =  "<div id='app-dialog'></div>";
//        $("#page").append($(dialogContainer));
//    }
//    else 
//    {
//        dialogContainer=$("#app-dialog");   
//    }
//    // $('#app-dialog').html(theContent);
//    theContent = '<input type="hidden" autofocus="autofocus" />' + theContent
//    theAppDialog =  $('#app-dialog').dialog({
//        autoOpen: false,
//        modal: true,
//        buttons: {
//            "Close": function() { 
//                // Do what needs to be done to complete 
//                $(this).dialog("close"); 
//            }
//        },
//        close: function( event, ui ) {
//            $('#app-dialog').html("");
//            $('#app-dialog').dialog( "destroy" );
//        },
//        open: function (event, ui)
//        {
//            popUpAlertifExists();
//        }
//        
//        
//    });
//    
//    $('#app-dialog').html(theContent);
//
//    theHeight= $('#app-dialog #dialog-height').text() || "500";
//    theWidth= $('#app-dialog #dialog-width').text()  || "500";
//    theTitle= $('#app-dialog #dialog-name').text() || "Edit";
//    
//    theAppDialog.dialog({
//        title:theTitle,
//        width: theWidth,
//        height:theHeight
//    });
//        
//    return(theAppDialog)
//}

function edit_page_dialog(data) {

    // alert("ajax:success");
    page_edit_dialog = createAppDialog(data, "edit-page", {}, "");

    //initialize_save_button();
    //$('.datepicker').datepicker();
    //tiny_mce_initializer();
    //bind_org_select();
    //bind_membership_select();
    //bind_grade_select();
    //bind_flags_select();

    //bind_grade_all_select();

    //bind_grade_filter_display();
    //bind_membership_filter_display();
    //bind_flags_filter_display();
    //bind_select_ajax("picture_priority");
    //bind_select_ajax("picture_status");



    //current_notice = $("#picture-id").text();
    //set_before_edit(current_notice);
    // tinyMCE.init({"selector":"textarea.tinymce"});
    // $(".best_in_place").best_in_place();

    //bind_file_upload_to_upload_form();
    //$("button.ui-dialog-titlebar-close").hide();

    //initialize_add_organization();
    //select_subject_field();
    //initialize_select_all_button();
    //initialize_select_none_button();
    //initilize_filter_buttons();

}

$(document).off('focusin').on('focusin', function(e) {
    if ($(event.target).closest(".mce-window").length) {
        e.stopImmediatePropagation();
    }
});