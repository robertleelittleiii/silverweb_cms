/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

function update_rolls_callDocumentReady()
{
    
    $('.role-check').change(
        function() {
            //user_id=$("#user-id").text().trim();
           var user_id=$(this).parent().parent().find("#user-id").text().trim();
            role_id=$(this).parent().find("#role-id").text().trim();
            console.log(this.checked);
    
    
            $.ajax({
                url: '/users/update_roles?id='+user_id+"&role_id="+ role_id + "&is_checked=" + this.checked , 
                success: function(data) 
                {
                
                }
            });
        });

}

$(document).ready(function() {

    if ($("#as_window").text()=="true") 
    {
    //  alert("it is a window");
    }
    else
    {
        update_rolls_callDocumentReady();
    }

});