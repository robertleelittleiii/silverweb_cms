var userTableAjax;
var admin_user_administration_callDocumentReady_called = false;

$(document).ready(function () {
    if (!admin_user_administration_callDocumentReady_called)
    {
        admin_user_administration_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        }
        else
        {
            admin_user_administration_callDocumentReady()
        }
    }

});


function admin_user_administration_callDocumentReady() {
    requireCss("tables.css");

    //  Required scripts (loaded for this js file)
    //

    createUserDialog();
    //    $("#loader_progress").show();
    //    userTableOld=$('#user-table-old').dataTable({
    //        "aLengthMenu": [[-1, 10, 25, 50], ["All", 10, 25, 50]]
    //    });
    $("#loader_progress").show();

    createUserTable();

    $("#loader_progress").hide();

    //
    //    $('#user-table .user-row').bind('click', function(){
    //        $(this).addClass('row_selected');
    //        userID=$(this).find("#user-id").text().strip();
    //        window.location = "/user/edit/"+userID;
    //    });

    //    $('.delete-user-item').bind('ajax:success', function(xhr, data, status){
    //        $("#loader_progress").show();
    //        theTarget=this.parentNode.parentNode;
    //        var aPos = userTableAjax.fnGetPosition( theTarget );
    //        userTableAjax.fnDeleteRow(aPos);
    //        userTableAjax.fnDraw();
    //        $("#loader_progress").hide();
    //    });

    //    $('.delete-user-item').bind('ajax:error', function(xhr, data, error){
    //        alert("Error:" + JSON.parse(data.responseText)["error"]);
    //        $("#loader_progress").hide();
    //
    //    });

    $(".edit_user").bind('ajax:success', function (xhr, data, status) {
        $('#edit-password-dialog').dialog('close');
    });

    $('#new-user').bind('ajax:beforeSend', function (e, xhr, settings) {
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("#loader_progress").show();
    });

    $('#new-user').bind('ajax:success', function (xhr, data, status) {
        $("#loader_progress").hide();
        userTableAjax.fnDraw();
        setUpPurrNotifier("Notice", "Default password is 'password'");
    });








    createPasswordDialog();
    createUserDialog();

}



function deleteUser(user_id)
{
    var answer = confirm('Are you sure you want to delete this user?')
    if (answer) {
        $.ajax({
            url: '/users/delete_ajax?id='+ user_id,
            
            success: function (data)
            {
                setUpPurrNotifier("Notice", "User Successfully Deleted.");
                userTableAjax.fnDraw();

            }
        });

    }
}

function bindDeleteUser() {
    $(".delete-user-item").on("click", function (e) {

        // console.log($(this).parent().parent().parent().find('#page-id').text());
        var user_id = $(this).parent().parent().parent().find('#user-id').text();
        deleteUser(user_id);
        return false;
    });
}


function createUserDialog() {

    $('#edit-user-dialog').dialog({
        autoOpen: false,
        width: 455,
        height: 625,
        modal: true,
        buttons: {
            "Delete": function () {
                user_id = $(".m-content div#user-id").text().trim();
                if (confirm("Are you sure you want to delete this user?"))

                {
                    $(this).dialog("close");

                    $.ajax({
                        url: '/users/delete_ajax?id=' + user_id,
                        success: function (data)
                        {
                            userTableAjax.fnDraw();
                        }
                    });
                }
                else
                {

                }
            },
            "Ok": function () {
                $(this).dialog("close");
                userTableAjax.fnDraw();
            }
        }

    });
}


function createPasswordDialog() {

    $('#edit-password-dialog').dialog({
        autoOpen: false,
        width: 706,
        height: 245,
        modal: true
    });
}



function usereditClickBinding() {
    $('.edit-user-item').click(function () {
        user_id = $(this).parent().parent().parent().find('#user-id').text().trim();

        $.ajax({
            url: '/users/update_roles' + '?id=+' + user_id + '&as_window=true',
            success: function (data)
            {
                editUserDialog = createAppDialog(data, "user-edit");
                editUserDialog.dialog('open');
                editUserDialog.dialog({
                    close: function (event, ui) {
                        userTableAjax.fnDraw();

                        editUserDialog.dialog("destroy");

                    }
                });
                require("users/update_roles.js");
                update_rolls_callDocumentReady();


                // setupRolesSelection();
            }
        });
    });
}

function passwordClickBinding() {
    $('.password-user-item').click(function () {
        user_id = $(this).parent().parent().parent().find('#user-id').text().trim();

        $.ajax({
            url: '/users/change_password?id=' + user_id + '&as_window=true',
            success: function (data)
            {
                editPasswordDialog = createAppDialog(data, "edit-password");

                // $('#edit-password-dialog').html(data);
                editPasswordDialog.dialog({
                    buttons: {}
                });
                editPasswordDialog.dialog('open');
                require("users/change_password.js");
                change_password_callDocumentReady();

                callbackFunction = function closethisDialog() {
                    editPasswordDialog.dialog('close');
                };
                bindChangePasswordClick(callbackFunction);
            }
        });
    });
}

function createUserTable() {
    userTableAjax = $('#user-table').dataTable({
        "bProcessing": true,
        "bServerSide": true,
        "sAjaxSource": "/users/user_table",
        "fnRowCallback": function (nRow, aData, iDisplayIndex, iDisplayIndexFull) {
            $(nRow).addClass('user-row');
            $(nRow).addClass('gradeA');
            return nRow;
        },
        "fnInitComplete": function () {
            // $(".best_in_place").best_in_place(); 

        },
        "fnDrawCallback": function () {
            $(".best_in_place").best_in_place();
            passwordClickBinding();
            usereditClickBinding();
           bindDeleteUser();

        }
    });
}


//function bindDeleteUser(callbackFunction) {
//    $('.delete-user-item').unbind('ajax:success');
//    $('.delete-user-item').bind('ajax:beforeSend', function (evt, xhr, settings) {
//        // alert("ajax:before");  
//        console.log('ajax:before');
//        console.log(evt);
//        console.log(xhr);
//        console.log(settings);
//
//        $("#loader_progress").show();
//
//
//
//    }).bind('ajax:success', function (evt, data, status, xhr) {
//        //  alert("ajax:success"); 
//        console.log('ajax:success');
//        console.log(evt);
//        console.log("date:" + data + ":");
//
//        $("#loader_progress").show();
//        theTarget = this.parentNode.parentNode;
//        var aPos = userTableAjax.fnGetPosition(theTarget);
//        userTableAjax.fnDeleteRow(aPos);
//        userTableAjax.fnDraw();
//        $("#loader_progress").hide();
//
//        if (typeof callbackFunction == 'function')
//        {
//            callbackFunction();
//        }
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
//        $("#loader_progress").hide();
//
//
//    }).bind('ajax:complete', function (evt, xhr, status) {
//        //    alert("ajax:complete");  
//        console.log('ajax:complete');
//        console.log(evt);
//        console.log(xhr);
//        // console.log(status);
//        $("#loader_progress").hide();
//
//
//    });
//
//}
function admin_user_administration_callDocumentReady() {
    requireCss("tables.css");

    //  Required scripts (loaded for this js file)
    //

    createUserDialog();
    //    $("#loader_progress").show();
    //    userTableOld=$('#user-table-old').dataTable({
    //        "aLengthMenu": [[-1, 10, 25, 50], ["All", 10, 25, 50]]
    //    });
    $("#loader_progress").show();

    createUserTable();

    $("#loader_progress").hide();

    //
    //    $('#user-table .user-row').bind('click', function(){
    //        $(this).addClass('row_selected');
    //        userID=$(this).find("#user-id").text().strip();
    //        window.location = "/user/edit/"+userID;
    //    });

    //    $('.delete-user-item').bind('ajax:success', function(xhr, data, status){
    //        $("#loader_progress").show();
    //        theTarget=this.parentNode.parentNode;
    //        var aPos = userTableAjax.fnGetPosition( theTarget );
    //        userTableAjax.fnDeleteRow(aPos);
    //        userTableAjax.fnDraw();
    //        $("#loader_progress").hide();
    //    });

    //    $('.delete-user-item').bind('ajax:error', function(xhr, data, error){
    //        alert("Error:" + JSON.parse(data.responseText)["error"]);
    //        $("#loader_progress").hide();
    //
    //    });

    $(".edit_user").bind('ajax:success', function (xhr, data, status) {
        $('#edit-password-dialog').dialog('close');
    });

    $('#new-user').bind('ajax:beforeSend', function (e, xhr, settings) {
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("#loader_progress").show();
    });

    $('#new-user').bind('ajax:success', function (xhr, data, status) {
        $("#loader_progress").hide();
        userTableAjax.fnDraw();
        setUpPurrNotifier("Notice", "Default password is 'password'");
    });








    createPasswordDialog();
    createUserDialog();

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
