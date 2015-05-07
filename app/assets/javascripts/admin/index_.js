/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

function index_callDocumentReady() 
{
                $("#tabs").tabs();

}

$(document).ready(function() {
    if ($("#as_window").text()=="true") 
    {
    //  alert("it is a window");
    }
    else
    {
        index_callDocumentReady()
    }

});

  