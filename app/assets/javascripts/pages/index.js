
pageTableAjax = "";


function deletePage(page_id)
{
    var answer=confirm('Are you sure you want to delete this?')
    if (answer) {
        $.ajax({
            url: '/pages/delete_ajax/'+page_id,
            success: function(data) 
            {
                setUpPurrNotifier("Notice","Item Successfully Deleted.");
                pageTableAjax.fnDraw();

            }
        });
    
    }
}

function editPage(page_id)
{
        var url='/pages/edit/'+page_id+'?request_type=window&window_type=iframe';
        $('iframe#pages-app-id',window.parent.document).attr("src",url);
}



function pageeditClickBinding(selector) {
   // selectors .edit-page-item, tr.page-row 
   
    $(selector).unbind("click").one("click",function(){
        console.log($(this).find('#page-id').text());
        var page_id = $(this).find('#page-id').text();
        var is_iframe = $("application-space").length > 0
        
        var url='/pages/edit/'+page_id+'?request_type=window&window_type=iframe';
        $(this).effect( "highlight", {color:"#669966"},1000 );
        if (is_iframe) {
                        $('iframe#pages-app-id',window.parent.document).attr("src",url);
                        pageeditClickBinding(this);
        }
        else
            {
                window.location = url;

            }

    });
}

function loadPageScreen() {
    
    page-action-area
}


function createPageDialog() {
    
    $('#edit-page-dialog').dialog({
        autoOpen: false,
        width: 455,
        height:625,
        modal:true,
        buttons: {
            "Delete":function() {
                page_id=$(".m-content div#page-id").text().trim();
                if (confirm("Are you sure you want to delete this page?")) 

                {
                    $(this).dialog("close"); 

                    $.ajax({

                        url: '/pages/delete_ajax?id='+ page_id, 
                        success: function(data) 
                        {
                            pageTableAjax.fnDraw();
                        }
                    });
                }
                else
                {
                        
                }
            },
            "Ok": function() { 
                $(this).dialog("close"); 
                pageTableAjax.fnDraw();
            }
        }
        
    });
}



function createPageTable() {
    pageTableAjax=$('#page-table').dataTable({
        "iDisplayLength": 25,
        "aLengthMenu": [[25, 50, 100], [25, 50, 100]],
        "bStateSave": true,
        "fnStateSave": function (oSettings, oData) {
            localStorage.setItem( 'DataTables_pages_'+window.location.pathname, JSON.stringify(oData) );
        },
        "fnStateLoad": function (oSettings) {
            return JSON.parse(localStorage.getItem('DataTables_pages_'+window.location.pathname) );
        },
        "bProcessing": true,
        "bServerSide": true,
        "aaSorting": [[ 1, "asc" ]],
        "sAjaxSource": "/pages/page_table",
        "fnRowCallback": function( nRow, aData, iDisplayIndex, iDisplayIndexFull ) {
            $(nRow).addClass('page-row');
            $(nRow).addClass('gradeA');
            return nRow;
        },
        "fnInitComplete": function () {
        // $(".best_in_place").best_in_place(); 
           
        },
        "fnDrawCallback":function () {
            $(".best_in_place").best_in_place(); 
            //pageeditClickBinding(".edit-page-item");
            pageeditClickBinding("tr.page-row");
            bindDeletePage();
        }
    });
}

function bindNewPage(){
    $('#new-page-link').bind('ajax:beforeSend', function(evt, xhr, settings) {  
        // alert("ajax:before");  
        console.log('ajax:before');
        console.log(evt);
        console.log(xhr);
        console.log(settings);
        
        $("#loader_progress").show();

        
        
    }).bind('ajax:success', function(evt, data, status, xhr ) {  
        //  alert("ajax:success"); 
        console.log('ajax:success');
        console.log(evt);
        console.log("date:" + data+":");
        
        $("#loader_progress").show();
        console.log(data.id);
        editPage(data.id);
       
        console.log(status);    
        console.log(xhr);

    }).bind('ajax:error', function(evt, xhr, status, error) {  
        // alert("ajax:failure"); 
        console.log('ajax:error');
        console.log(evt);
        console.log(xhr);
        console.log(status);
        console.log(error);
        
        alert("Error:" + JSON.parse(data.responseText)["error"]);
        $("#loader_progress").hide();

        
    }).bind('ajax:complete', function(evt, xhr, status) {  
        //    alert("ajax:complete");  
        console.log('ajax:complete');
        console.log(evt);
        console.log(xhr);
        // console.log(status);
        $("#loader_progress").hide();


    }); 
    
}
function bindDeletePage() {
    $(".delete-page-item").on("click",function(e){

                // console.log($(this).parent().parent().parent().find('#page-id').text());
                var page_id = $(this).parent().parent().parent().find('#page-id').text();
                deletePage(page_id);
                return false;
            });
}


function index_callDocumentReady(){
    requireCss("tables.css");
    
     if ($('#mainnav:visible').length != 0)
    {
        $("div#page-middle-left").hide();
        $("div#content").width("100%");
        $('#Content').css('background',"white")
    }
    
    //  Required scripts (loaded for this js file)
    //

    // reatePageDialog();
    //    $("#loader_progress").show();
    //    pageTableOld=$('#page-table-old').dataTable({
    //        "aLengthMenu": [[-1, 10, 25, 50], ["All", 10, 25, 50]]
    //    });
    $("#loader_progress").show();
    
    createPageTable();
    
    $("#loader_progress").hide();

    //
    //    $('#page-table .page-row').bind('click', function(){
    //        $(this).addClass('row_selected');
    //        pageID=$(this).find("#page-id").text().strip();
    //        window.location = "/page/edit/"+pageID;
    //    });
  
    //    $('.delete-page-item').bind('ajax:success', function(xhr, data, status){
    //        $("#loader_progress").show();
    //        theTarget=this.parentNode.parentNode;
    //        var aPos = pageTableAjax.fnGetPosition( theTarget );
    //        pageTableAjax.fnDeleteRow(aPos);
    //        pageTableAjax.fnDraw();
    //        $("#loader_progress").hide();
    //    });
    
    //    $('.delete-page-item').bind('ajax:error', function(xhr, data, error){
    //        alert("Error:" + JSON.parse(data.responseText)["error"]);
    //        $("#loader_progress").hide();
    //
    //    });

    $(".edit_page").bind('ajax:success', function(xhr, data, status){
        $('#edit-password-dialog').dialog('close');
    });
    
    $('#new-page').bind('ajax:beforeSend', function(e, xhr, settings){
        xhr.setRequestHeader('accept', '*/*;q=0.5, text/html, ' + settings.accepts.html);
        $("#loader_progress").show();
    });
    
    $('#new-page').bind('ajax:success', function(xhr, data, status){
        $("#loader_progress").hide();
        pageTableAjax.fnDraw();
        setUpPurrNotifier("Notice","Default password is 'password'");
    });

    
    createPasswordDialog();
    createPageDialog();
    bindNewPage();
}


$(document).ready(function() {
    if ($("#as_window").text()=="true") 
    {
      //  alert("it is a window");
    }
    else
    {

        index_callDocumentReady();
    }

});

            
// ************************************    
//
// Create Edit Dialog Box
//
// ************************************    

function createAppDialog(theContent) {
    
        
    if ($("#app-dialog").length == 0) 
    {    
        var dialogContainer =  "<div id='app-dialog'></div>";
        $("#page").append($(dialogContainer));
    }
    else 
    {
        dialogContainer=$("#app-dialog");   
    }
    // $('#app-dialog').html(theContent);
    theContent = '<input type="hidden" autofocus="autofocus" />' + theContent
    theAppDialog =  $('#app-dialog').dialog({
        autoOpen: false,
        modal: true,
        buttons: {
            "Close": function() { 
                // Do what needs to be done to complete 
                $(this).dialog("close"); 
            }
        },
        close: function( event, ui ) {
            $('#app-dialog').html("");
            $('#app-dialog').dialog( "destroy" );
        },
        open: function (event, ui)
        {
            popUpAlertifExists();
        }
        
        
    });
    
    $('#app-dialog').html(theContent);

    theHeight= $('#app-dialog #dialog-height').text() || "500";
    theWidth= $('#app-dialog #dialog-width').text()  || "500";
    theTitle= $('#app-dialog #dialog-name').text() || "Edit";
    
    theAppDialog.dialog({
        title:theTitle,
        width: theWidth,
        height:theHeight
    });
        
    return(theAppDialog)
}
