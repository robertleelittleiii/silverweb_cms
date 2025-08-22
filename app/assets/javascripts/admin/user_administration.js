var userTableAjax;
var admin_user_administration_callDocumentReady_called = false;

$(document).ready(function () {
    if (!admin_user_administration_callDocumentReady_called)
    {
        admin_user_administration_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
            //  alert("it is a window");
        } else
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
    //    userTableOld=$('#user-table-old').DataTable({
    //        "aLengthMenu": [[-1, 10, 25, 50], ["All", 10, 25, 50]]
    //    });
    $("#loader_progress").show();

    createUserTable();

    $("#loader_progress").hide();

    $(".edit_user").bind('ajax:success', function (xhr, data, status) {
        $('#edit-password-dialog').dialog('close');
    });

    $('#new-user').bind('ajax:beforeSend', function (e, xhr, settings) {
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("#loader_progress").show();
    });

    $('#new-user').bind('ajax:success', function (xhr, data, status) {
        $("#loader_progress").hide();
        userTableAjax.draw();
        setUpPurrNotifier("Notice", "Default password is 'password'");
    });








    createPasswordDialog();
    createUserDialog();
    ui_ajax_select();


}



function deleteUser(user_id)
{
    var answer = confirm('Are you sure you want to delete this user?')
    if (answer) {
        $.ajax({
            url: '/users/delete_ajax?id=' + user_id,
            success: function (data)
            {
                setUpPurrNotifier("Notice", "User Successfully Deleted.");
                userTableAjax.draw();

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
                            userTableAjax.draw();
                        }
                    });
                } else
                {

                }
            },
            "Ok": function () {
                $(this).dialog("close");
                userTableAjax.draw();
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
                        userTableAjax.draw();
                        
                        editUserDialog.dialog("destroy");
                        editUserDialog.html("");
                        editUserDialog.remove();
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
    userTableAjax = $('#user-table').DataTable({
        pageLength: 25,
        lengthMenu: [[25, 50, 100], [25, 50, 100]],
        stateSave: true,
        stateSaveCallback: function (settings, data) {
            localStorage.setItem('DataTables_user_administration_' + window.location.pathname, JSON.stringify(data));
        },
        stateLoadCallback: function (settings) {
            return JSON.parse(localStorage.getItem('DataTables_user_administration_' + window.location.pathname));
        },
        processing: true,
        order: [[0, "asc"]],
        serverSide: true,
        searchDelay: 500,
        ajax: {
            url: "/users/user_table",
            type: "post"
        },
        rowCallback: function (row, data, index) {
            $(row).addClass('user-row');
            $(row).addClass('gradeA');
            //return row;
        },
        initComplete: function () {
            // $(".best_in_place").best_in_place(); 

        },
        drawCallback: function (settings) {
            $(".best_in_place").best_in_place();
            passwordClickBinding();
            usereditClickBinding();
            bindDeleteUser();
            ui_ajax_select();
            $("td.dataTables_empty").attr("colspan", "20")

        }
    });
}

