/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

var live_edit_interval;

    function live_edit_loaded(){
    return true;
};

function refresh_user_live_edit() {

    var object_class = $($("div.object-info").last()).find("div#object-class").text().toLowerCase() + "s";
    var current_action = $($("div.object-info").last()).find("div#object-action").text();
    var the_id = $($("div.object-info").last()).find("div#object-id").text();

    if (object_class == "s")
        {
            object_class = "admin"
        }
        
    $.ajax({
        url: "/" + object_class + "/refresh_user_live_edit",
        dataType: "html",
        type: "POST",
        data: {user_action_name: current_action, id: the_id},
        success: function(data)
        {
            console.log(data);

        }
    });

}

function updateUserField(current_field) {

    var object_class = $($("div.object-info").last()).find("div#object-class").text().toLowerCase() + "s";
    
    if (object_class != "s") { // found a trackable field
    $.ajax({
        url: "/" + object_class + "/update_user_field",
        dataType: "html",
        type: "POST",
        data: {current_field: current_field},
        success: function(data)
        {
            console.log(data);

        }
    });

    }
}

function updateUserList()
{
    if ($("div#active-user-list").length > 0) {
        $($("div.object-info").last()).find("div#object-id").text()
        var object_id = $($("div.object-info").last()).find("div#object-id").text()
        var object_class = $($("div.object-info").last()).find("div#object-class").text().toLowerCase() + "s";
        var object_action = $($("div.object-info").last()).find("div#object-action").text()

        $.ajax({
            url: "/" + object_class + "/update_user_list",
            dataType: "html",
            type: "POST",
            data: {id: object_id},
            success: function(data)
            {
                object_name = $($("div.object-info").last()).find("div#object-class").text().toLowerCase()
              //  console.log("div#" + object_name + " div#active-user-list");
                $("div#" + object_name + " div#active-user-list").html(data);
                processBestInPlaceFields();
                updated_changed_fields();
                if ($("#"+ object_name +"-app-dialog #user-info-block").length > 0)
                {
                    if ($("#"+ object_name +"-app-dialog").length > 0) {
                        $("#"+ object_name +"-app-dialog").css("padding-top", "35px");
                        $("#"+ object_name +"-app-dialog div#active-user-list").css("margin-top", "-32px");
                    }

                }
                else
                {
                    if ($("#"+ object_name +"-app-dialog").length > 0) {
                        $("#"+ object_name +"-app-dialog").css("padding-top", "")
                        $("#"+ object_name +"-app-dialog div#active-user-list").css("margin-top", "")
                    }

                }
                // console.log(data);

            }
        });
    }

}

function check_lock_status() {
    update_user_status();
    
    check_lock_status = $("#check_lock_status").text().trim();
    
    check_lock_status = check_lock_status == "" ? 1000 : check_lock_status
    
    if (typeof live_edit_interval != "number") {
        live_edit_interval = setInterval(function() {
            update_user_status();
        }, check_lock_status);
    }

}

function update_user_status() {
    updateUserList();
}

function BestInPlaceCallBackBind(input) {
    console.log("BestInPlaceCallBackBind");
    console.log(input);
    console.log("------------------------------------------")
    updateUserField(input.attributeName);
}

function BestInPlaceCallBack(input) {
    console.log("BestInPlaceCallBack");
    console.log(input);
    console.log("------------------------------------------")

    updateUserField(null);
}

function BestInPlaceCallBackNoChange(input) {
    if ($("form.form_in_place").length == 0) {
        console.log("BestInPlaceCallBackNoChange");
        console.log(input);
        console.log("------------------------------------------")


        updateUserField(null);
    }
}


function processBestInPlaceFields() {
    var object_class = $($("div.object-info").last()).find("div#object-class").text().toLowerCase()
    var userList = jQuery.parseJSON($("div#" + object_class + " div#live-edit-json").text())
    var live_edit_name = "best_in_place"
    $.each(userList, function(index, value) {
        console.log("----- start ----");
        console.log(value);
        if (value.current_field != null) {
            field_to_update = "div#" + object_class +" #" + live_edit_name + "_" + object_class + "_" + value.current_field;
            field_object = $(field_to_update);
            $(field_object).addClass("locked");
            $(field_object).addClass("user-" + index);
            $(field_object).removeClass(live_edit_name);

            console.log(field_object)
        }
        console.log(field_to_update)
        console.log(index + ": " + value);
        console.log(value);
        console.log(live_edit_name + "_" + object_class + "_" + value.current_field);
        console.log("----- end ----");


    });

}


function updated_changed_fields() {

    var fields_being_edited = $("div.locked");
    var object_class = $($("div.object-info").last()).find("div#object-class").text().toLowerCase();
    var userList = jQuery.parseJSON($("div#" + object_class + " div#live-edit-json").text());

    $.each(fields_being_edited, function(edit_index, edit_value) {
        item_found = false;
        $.each(userList, function(index, value) {
            console.log($(edit_value).attr("data-attribute"));
            console.log(value.current_field);
            if ($(edit_value).attr("data-attribute") == value.current_field) 
            {
                item_found = true;
            }
        });

        if (!item_found) {
            console.log("this was not found");
            reload_best_in_place_item($(edit_value));
        }

    });

}

function reload_best_in_place_item(the_item) {
    the_id = the_item.attr("id")
    var object_class_id = $(the_item).attr("data-object");
    var object_format = $(the_item).attr("data-format");

    $("div#" + object_class_id +" #" + the_id).attr("class", "");
    $("div#" + object_class_id +" #" + the_id).addClass("best_in_place");

    var object_class = object_class_id + "s";
    var object_field = $(the_item).attr("data-attribute");
    var object_id = $($("div.object-info").last()).find("div#object-id").text()

    $.ajax({
        url: "/" + object_class + "/get_field",
        dataType: "html",
        type: "POST",
        data: {field_name: object_field, id: object_id, format_string: object_format},
        success: function(data)
        {
            $("div#" + object_class_id +" #" + the_id).text(data);
            $("div#" + object_class_id +" #" + the_id).best_in_place();
            console.log("div#" + object_class_id +" #" + the_id);
            console.log(data);

        }
    });

}