/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */


var admin_index_callDocumentReady_called = false;
$(document).ready(function () {
    if (!admin_index_callDocumentReady_called)
    {
        admin_index_callDocumentReady_called = true;
        if ($("#as_window").text() == "true")
        {
//  alert("it is a window");
        }
        else
        {
            admin_index_callDocumentReady()
        }
    }

});

function admin_index_callDocumentReady() 
{
                $("#tabs").tabs();
                $("div.button-link").button();
                passwordClickBinding();
                ui_ajax_select();

}



  
  
  function passwordClickBinding() {
    $('div#password-user-item').click(function () {
        user_id = $("div#user-id").text().trim();

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