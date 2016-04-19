var rightTableAjax;
var rights_index_callDocumentReady_called = false;
$(document).ready(function () {
    if (!rights_index_callDocumentReady_called)
    {
        rights_index_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
//  alert("it is a window");
        } else
        {
            rights_index_callDocumentReady()
        }
    }
});
function rights_index_callDocumentReady() {
    requireCss("tables.css");
    //  Required scripts (loaded for this js file)
    //

    createRightDialog();
    //    $("#loader_progress").show();
    //    rightTableOld=$('#right-table-old').DataTable({
    //        "aLengthMenu": [[-1, 10, 25, 50], ["All", 10, 25, 50]]
    //    });
    $("#loader_progress").show();
    createRightTable();
    $("#loader_progress").hide();
    //
    //    $('#right-table .right-row').bind('click', function(){
    //        $(this).addClass('row_selected');
    //        rightID=$(this).find("#right-id").text().strip();
    //        window.location = "/right/edit/"+rightID;
    //    });

    //    $('.delete-right-item').bind('ajax:success', function(xhr, data, status){
    //        $("#loader_progress").show();
    //        theTarget=this.parentNode.parentNode;
    //        var aPos = rightTableAjax.fnGetPosition( theTarget );
    //        rightTableAjax.fnDeleteRow(aPos);
    //        rightTableAjax.draw();
    //        $("#loader_progress").hide();
    //    });

    //    $('.delete-right-item').bind('ajax:error', function(xhr, data, error){
    //        alert("Error:" + JSON.parse(data.responseText)["error"]);
    //        $("#loader_progress").hide();
    //
    //    });

    $(".edit_right").bind('ajax:success', function (xhr, data, status) {
        $('#edit-password-dialog').dialog('close');
    });
    $('a#new-right').bind('ajax:beforeSend', function (e, xhr, settings) {
        console.log("before");
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("#loader_progress").show();
    }).bind('ajax:success', function (evt, data, status, xhr) {
        console.log("successs");
        $("#loader_progress").hide();
        rightTableAjax.draw();
        setUpPurrNotifier("Notice", "New Right has been created.");
    }).bind('ajax:error', function (evt, xhr, status, error) {
        console.log('ajax:error');
        console.log(evt);
        console.log(xhr);
        console.log(status);
        console.log(error);
    }).bind('ajax:complete', function (evt, xhr, status) {
        console.log('ajax:complete');
        console.log(evt);
        console.log(xhr);
        // console.log(status);
    });
    createRightDialog();
}





function createRightDialog() {

    $('#edit-right-dialog').dialog({
        autoOpen: false,
        width: 455,
        height: 625,
        modal: true,
        buttons: {
            "Delete": function () {
                right_id = $(".m-content div#right-id").text().trim();
                if (confirm("Are you sure you want to delete this right?"))

                {
                    $(this).dialog("close");
                    $.ajax({
                        url: '/rights/delete_ajax?id=' + right_id,
                        success: function (data)
                        {
                            rightTableAjax.draw();
                        }
                    });
                } else
                {

                }
            },
            "Ok": function () {
                $(this).dialog("close");
                rightTableAjax.draw();
            }
        }

    });
}





function righteditClickBinding() {
    $('.edit-right-item').click(function () {
        right_id = $(this).parent().parent().parent().find('#right-id').text().trim();
        $.ajax({
            url: '/rights/update_actions' + '?id=+' + right_id + '&as_window=true',
            success: function (data)
            {
                editRightDialog = createAppDialog(data, "edit-right");
                editRightDialog.dialog('open');
                editRightDialog.dialog({
                    close: function (event, ui) {
                        rightTableAjax.draw();
                        editRightDialog.html("");
                        editRightDialog.dialog("destroy");
                    }
                });
                require("rights/update_actions.js");
                update_actions_callDocumentReady();
                // setupRightsSelection();
            }
        });
    });
}



function createRightTable() {
    rightTableAjax = $('#right-table').DataTable({
        pageLength: 25,
        lengthMenu: [[25, 50, 100], [25, 50, 100]],
        stateSave: true,
        stateSaveCallback: function (settings, data) {
            localStorage.setItem('DataTables_rights_' + window.location.pathname, JSON.stringify(data));
        },
        stateLoadCallback: function (settings) {
            return JSON.parse(localStorage.getItem('DataTables_rights_' + window.location.pathname));
        },
        processing: true,
        order: [[0, "asc"]],
        serverSide: true,
        searchDelay: 500,
        ajax: {
            url: "/rights/right_table",
            type: "post"
        },
        rowCallback: function (row, data, index) {
            $(row).addClass('right-row');
            $(row).addClass('gradeA');
            //return row;
        },
        initComplete: function () {
            // $(".best_in_place").best_in_place(); 

        },
        drawCallback: function (settings) {
            $(".best_in_place").best_in_place();
            righteditClickBinding();
            bindDeleteRight();
                ui_ajax_select();

            $("td.dataTables_empty").attr("colspan", "20")

        }

//"bProcessing": true,
//        "bServerSide": true,
//        "sAjaxSource": "/rights/right_table",
//        "fnRowCallback": function (nRow, aData, iDisplayIndex, iDisplayIndexFull) {
//        $(nRow).addClass('right-row');
//                $(nRow).addClass('gradeA');
//                return nRow;
//        },
//        "fnInitComplete": function () {
//        // $(".best_in_place").best_in_place(); 
//
//        },
//        "drawCallback": function () {
//        $(".best_in_place").best_in_place();
//                righteditClickBinding();
//                bindDeleteRight();
//        }
    });
}

function deleteRight(right_id)
{
    var answer = confirm('Are you sure you want to delete this right? (it cannot be undone)')
    if (answer) {
        $.ajax({
            url: '/rights/delete_ajax?id=' + right_id,
            success: function (data)
            {
                setUpPurrNotifier("Notice", "Right Successfully Deleted.");
                rightTableAjax.draw();

            }
        });

    }
}

function bindDeleteRight() {
    $(".delete-right-item").on("click", function (e) {

        // console.log($(this).parent().parent().parent().find('#page-id').text());
        var right_id = $(this).parent().parent().parent().find('#right-id').text();
        deleteRight(right_id);
        return false;
    });
}

//
//function bindDeleteRight(callbackFunction) {
//    $('.delete-right-item').unbind('ajax:success');
//    $('.delete-right-item').bind('ajax:beforeSend', function (evt, xhr, settings) {
//// alert("ajax:before");  
//        console.log('ajax:before');
//        console.log(evt);
//        console.log(xhr);
//        console.log(settings);
//        $("#loader_progress").show();
//    }).bind('ajax:success', function (evt, data, status, xhr) {
////  alert("ajax:success"); 
//        console.log('ajax:success');
//        console.log(evt);
//        console.log("date:" + data + ":");
//        $("#loader_progress").show();
//        theTarget = this.parentNode.parentNode;
//        var aPos = rightTableAjax.fnGetPosition(theTarget);
//        rightTableAjax.fnDeleteRow(aPos);
//        rightTableAjax.draw();
//        $("#loader_progress").hide();
//        if (typeof callbackFunction == 'function')
//        {
//            callbackFunction();
//        }
//
//        console.log(status);
//        console.log(xhr);
//    }).bind('ajax:error', function (evt, xhr, status, error) {
//// alert("ajax:failure"); 
//        console.log('ajax:error');
//        console.log(evt);
//        console.log(xhr);
//        console.log(status);
//        console.log(error);
//        alert("Error:" + JSON.parse(data.responseText)["error"]);
//        $("#loader_progress").hide();
//    }).bind('ajax:complete', function (evt, xhr, status) {
////    alert("ajax:complete");  
//        console.log('ajax:complete');
//        console.log(evt);
//        console.log(xhr);
//        // console.log(status);
//        $("#loader_progress").hide();
//    });
//}




// ************************************    
//
// Create Edit Dialog Box
//
// ************************************    

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
