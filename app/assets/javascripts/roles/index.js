var roleTableAjax;
var roles_index_callDocumentReady_called = false;

$(document).ready(function () {
    if (!roles_index_callDocumentReady_called)
    {
        roles_index_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        }
        else
        {
            roles_index_callDocumentReady()
        }
    }
});


function roles_index_callDocumentReady() {
    requireCss("tables.css");

    //  Required scripts (loaded for this js file)
    //

    createRoleDialog();
    //    $("#loader_progress").show();
    //    roleTableOld=$('#role-table-old').dataTable({
    //        "aLengthMenu": [[-1, 10, 25, 50], ["All", 10, 25, 50]]
    //    });
    $("#loader_progress").show();

    createRoleTable();

    $("#loader_progress").hide();

    //
    //    $('#role-table .role-row').bind('click', function(){
    //        $(this).addClass('row_selected');
    //        roleID=$(this).find("#role-id").text().strip();
    //        window.location = "/role/edit/"+roleID;
    //    });

    //    $('.delete-role-item').bind('ajax:success', function(xhr, data, status){
    //        $("#loader_progress").show();
    //        theTarget=this.parentNode.parentNode;
    //        var aPos = roleTableAjax.fnGetPosition( theTarget );
    //        roleTableAjax.fnDeleteRow(aPos);
    //        roleTableAjax.fnDraw();
    //        $("#loader_progress").hide();
    //    });

    //    $('.delete-role-item').bind('ajax:error', function(xhr, data, error){
    //        alert("Error:" + JSON.parse(data.responseText)["error"]);
    //        $("#loader_progress").hide();
    //
    //    });

    $(".edit_role").bind('ajax:success', function (xhr, data, status) {
        $('#edit-password-dialog').dialog('close');
    });

    $('a#new-role').bind('ajax:beforeSend', function (e, xhr, settings) {
        console.log("before");
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("#loader_progress").show();
    }).bind('ajax:success', function (evt, data, status, xhr) {
        console.log("successs");
        $("#loader_progress").hide();
        roleTableAjax.fnDraw();
        setUpPurrNotifier("Notice", "New Role has been created.");
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










    createRoleDialog();

}





function createRoleDialog() {

    $('#edit-role-dialog').dialog({
        autoOpen: false,
        width: 455,
        height: 625,
        modal: true,
        buttons: {
            "Delete": function () {
                role_id = $(".m-content div#role-id").text().trim();
                if (confirm("Are you sure you want to delete this role?"))

                {
                    $(this).dialog("close");

                    $.ajax({
                        url: '/roles/delete_ajax?id=' + role_id,
                        success: function (data)
                        {
                            roleTableAjax.fnDraw();
                        }
                    });
                }
                else
                {

                }
            },
            "Ok": function () {
                $(this).dialog("close");
                roleTableAjax.fnDraw();
            }
        }

    });
}





function roleeditClickBinding() {
    $('.edit-role-item').click(function () {
        role_id = $(this).parent().parent().parent().find('#role-id').text().trim();

        $.ajax({
            url: '/roles/update_rights' + '?id=+' + role_id + '&as_window=true',
            success: function (data)
            {
                editRoleDialog = createAppDialog(data, "edit-role");
                editRoleDialog.dialog('open');
                editRoleDialog.dialog({
                    close: function (event, ui) {
                        roleTableAjax.fnDraw();
                       editRoleDialog.html("");
                       editRoleDialog.dialog("destroy");

                    }
                });
                require("roles/update_rights.js");
                update_rights_callDocumentReady();


                // setupRolesSelection();
            }
        });
    });
}



function createRoleTable() {
    roleTableAjax = $('#role-table').dataTable({
        "bProcessing": true,
        "bServerSide": true,
        "sAjaxSource": "/roles/role_table",
        "fnRowCallback": function (nRow, aData, iDisplayIndex, iDisplayIndexFull) {
            $(nRow).addClass('role-row');
            $(nRow).addClass('gradeA');
            return nRow;
        },
        "fnInitComplete": function () {
            // $(".best_in_place").best_in_place(); 

        },
        "fnDrawCallback": function () {
            $(".best_in_place").best_in_place();
            roleeditClickBinding();
            bindDeleteRole();
        }
    });
}


function bindDeleteRole(callbackFunction) {
    $('.delete-role-item').unbind('ajax:success');
    $('.delete-role-item').bind('ajax:beforeSend', function (evt, xhr, settings) {
        // alert("ajax:before");  
        console.log('ajax:before');
        console.log(evt);
        console.log(xhr);
        console.log(settings);

        $("#loader_progress").show();



    }).bind('ajax:success', function (evt, data, status, xhr) {
        //  alert("ajax:success"); 
        console.log('ajax:success');
        console.log(evt);
        console.log("date:" + data + ":");

        $("#loader_progress").show();
        theTarget = this.parentNode.parentNode;
        var aPos = roleTableAjax.fnGetPosition(theTarget);
        roleTableAjax.fnDeleteRow(aPos);
        roleTableAjax.fnDraw();
        $("#loader_progress").hide();

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

        alert("Error:" + JSON.parse(data.responseText)["error"]);
        $("#loader_progress").hide();


    }).bind('ajax:complete', function (evt, xhr, status) {
        //    alert("ajax:complete");  
        console.log('ajax:complete');
        console.log(evt);
        console.log(xhr);
        // console.log(status);
        $("#loader_progress").hide();


    });

}




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
