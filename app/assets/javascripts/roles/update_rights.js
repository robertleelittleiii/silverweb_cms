/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

function update_rights_callDocumentReady()
{
    
    $('.right-check').change(
        function() {
            //user_id=$("#user-id").text().trim();
            role_id=$(this).parent().parent().find("#role-id").text().trim();
            right_id=$(this).parent().find("#right-id").text().trim();
            console.log(this.checked);
    
    
            $.ajax({
                url: '/roles/update_rights?id='+role_id+"&right_id="+ right_id + "&is_checked=" + this.checked , 
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
        update_rights_callDocumentReady();
    }

});