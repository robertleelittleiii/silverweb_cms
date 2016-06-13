/*
 BestInPlace (for jQuery)
 version: 0.1.0 (01/01/2011)
 @requires jQuery >= v1.4
 @requires jQuery.purr to display pop-up windows
 
 By Bernat Farrero based on the work of Jan Varwig.
 Examples at http://bernatfarrero.com
 
 Licensed under the MIT:
 http://www.opensource.org/licenses/mit-license.php
 
 Usage:
 
 Attention.
 The format of the JSON object given to the select inputs is the following:
 [["key", "value"],["key", "value"]]
 The format of the JSON object given to the checkbox inputs is the following:
 ["falseValue", "trueValue"]
 */

//  rll 2013/11  this is a modified version from the gem released in 2011.  
//   TBD:  Rollback into public gem
//
// require jquery.autosize
//= require jquery.caret
//= require jquery.notify.js
//= require jquery.autoGrowInput.js

var notice = ""

function wait(msecs)
{
    var start = new Date().getTime();
    var cur = start
    while (cur - start < msecs)
    {
        cur = new Date().getTime();
    }
}


function autoGrowInput(o, inputField) {

    o = jQuery.extend({
        maxWidth: 1000,
        minWidth: 5,
        comfortZone: 2
    }, o);
    jQuery(inputField).filter('input:text').each(function () {

        var minWidth = o.minWidth || jQuery(inputField).width(),
                val = '',
                input = jQuery(inputField),
                testSubject = jQuery('<tester/>').css({
            position: 'absolute',
            top: -9999,
            left: -9999,
            width: 'auto',
            fontSize: input.css('fontSize'),
            fontFamily: input.css('fontFamily'),
            fontWeight: input.css('fontWeight'),
            letterSpacing: input.css('letterSpacing'),
            whiteSpace: 'nowrap'
        }),
                check = function () {

                    if (val === (val = input.val())) {
                        return;
                    }

                    // Enter new content into testSubject
                    var escaped = val.replace(/&/g, '&amp;').replace(/\s/g, ' ').replace(/</g, '&lt;').replace(/>/g, '&gt;');
                    testSubject.html(escaped);
                    // Calculate new width + whether to change
                    var testerWidth = testSubject.width(),
                            newWidth = (testerWidth + o.comfortZone) >= minWidth ? testerWidth + o.comfortZone : minWidth,
                            currentWidth = input.width(),
                            isValidWidthChange = (newWidth < currentWidth && newWidth >= minWidth)
                            || (newWidth > minWidth && newWidth < o.maxWidth);
                    // Animate width
                    if (isValidWidthChange) {
                        input.width(newWidth);
                    }

                };
        testSubject.insertAfter(input);
        jQuery(this).bind('hover keyup keydown blur update focus', check);
    });
    return this;
}
;
// stub for success

function BestInPlaceCallBack(input) {
    // console.log("-- BestInPlaceCallBack --");
}
;
function BestInPlaceCallBackInit(input) {
    // console.log("-- BestInPlaceCallBackInit --");

}
;
function BestInPlaceCallBackBind(input) {
    // console.log("-- BestInPlaceCallBackBind --");

}
;
function BestInPlaceCallBackNoChange(input) {
    // console.log("-- BestInPlaceCallBackNoChange --");

}
;
function BestInPlaceEditor(e) {
    this.element = jQuery(e);
    this.initOptions();
    this.bindForm();
    this.initNil();
    jQuery(this.activator).unbind('click');
    jQuery(this.activator).bind('click', {
        editor: this
    }, this.clickHandler);
}

function BestInPlaceEditorObject(e) {
    if (jQuery(e).length==0) 
    {
        return ([]);
        
    }
    if (typeof jQuery(this).data('bestInPlaceEditor') == "undefined") {
        jQuery(e).best_in_place();
    }


    return jQuery(e).data().bestInPlaceEditor;
}


jQuery.fn.best_in_place_callback = function (hook_name, function_code) {
    this.each(function () {
        if (typeof jQuery(this).data('bestInPlaceEditor') == "undefined") {
            jQuery(e).best_in_place();
        }        
        jQuery(this).data('bestInPlaceEditor')[hook_name] = function_code;
    });
    return this;
}

function BestInPlaceEditorGroup(e) {

}

BestInPlaceEditor.prototype = {
// Public Interface Functions //////////////////////////////////////////////

    activate: function () {
        // this.isNil = (this.element.html() == "");
        this.initNil();
        var elem = ((this.isNil) | (this.element.html() == '<div class="data-nil">' + this.nil + '</div>')) ? "" : this.element.html();
//        console.log("----------------------------------------------------------");
//        console.log("'" + elem + "'");
//        console.log("'" + this.getValue() + "'");
//        console.log("'" + "<div class='data-nil'>" + this.nil + "</div>" + "'");
//        console.log(elem == "<div class='data-nil'>" + this.nil + "</div>");
//        console.log(this);
//        console.log(this.element);  
//        console.log(this.element.html());  
//        console.log(this.isNil);
//        console.log("----------------------------------------------------------");
        this.oldValue = elem;
        jQuery(this.activator).unbind("click", this.clickHandler);
        this.activateForm();
    },
    abort: function () {
       if (this.isNil)
            this.element.html("<div class='data-nil'>" + this.nil + "</div>");
        else
            this.element.html(this.oldValue);
        jQuery(this.activator).bind('click', {
            editor: this
        }, this.clickHandler);
    },
    update: function () {
        // console.log(this.getValue());
        // console.log(this.oldValue);
        // console.log(!this.dirty == "true");

        var editor = this;
        if (this.formType in {
            "input": 1,
            "textarea": 1,
            "date": 1
        } && this.getValue() == this.oldValue)
                //       } && this.getValue() == this.oldValue && !this.dirty == "true")
                { // Avoid request if no change is made
                    this.abort();
                    // console.log("-------------------------------------------");
                    // console.log("Testing callBackNoChange:");
                    // console.log(this);
                    // console.log(typeof this.callBackNoChange);

                    BestInPlaceCallBackNoChange(this);
                    if (typeof (this.callBackNoChange) == "function")
                    {
                        this.callBackNoChange(this);
                    }

                    return true;
                }

        // if it is empty then the result is nil/empty
        this.isNil = (this.getValue() == "");
        BestInPlaceCallBackInit(this);
        // console.log("-------------------------------------------");
        // console.log("Testing callBackInit:");
        // console.log(this);
        // console.log(typeof this.callBackInit);

        if (typeof (this.callBackInit) == "function")
        {
            this.callBackInit(this);
        }

        var current_editor = this;
        editor.ajax({
            "type": "post",
            "dataType": "text",
            "data": editor.requestData(),
            "success": function (data) {
                BestInPlaceCallBack(current_editor);
                // console.log("-------------------------------------------");
                // console.log("Testing callBackSuccess:");
                // console.log(current_editor);
                // console.log(typeof current_editor.callBackSuccess);

                current_editor.isNil = (current_editor.element.html() == "");
                current_editor.oldValue = (current_editor.element.html());
                
                if (typeof (current_editor.callBackSuccess) == "function")
                {
                    current_editor.callBackSuccess(current_editor);
                }

                //old way BestInPlaceCallBack(editor);

                //               console.log("successfull");
                //               console.log(data);
                current_editor.loadSuccessCallback(data);
            },
            "error": function (request, error) {
                //          console.log("an error occured");
                //           console.log(error);
                //          console.log(request);
                current_editor.loadErrorCallback(request, error);
                //current_editor.abort();
            }
        });
        if (this.formType == "select") {
            var value = this.getValue();
            jQuery.each(this.values, function (i, v) {
                if (value == v[0]) {
                    editor.element.html(v[1]);
                }
            }
            );
        } else if (this.formType == "checkbox") {
            editor.element.html(this.getValue() ? this.values[1] : this.values[0]);
        } else {
            editor.element.html(this.getValue());
        }
    },
    activateForm: function () {
        alert("The form was not properly initialized. activateForm is unbound");
    },
    // Helper Functions ////////////////////////////////////////////////////////

    initOptions: function () {
        // Try parent supplied info
        var self = this;
        self.element.parents().each(function () {
            self.url = self.url || jQuery(this).attr("data-url");
            self.collection = self.collection || jQuery(this).attr("data-collection");
            self.formType = self.formType || jQuery(this).attr("data-type");
            self.objectName = self.objectName || jQuery(this).attr("data-object");
            self.attributeName = self.attributeName || jQuery(this).attr("data-attribute");
            self.nil = self.nil || jQuery(this).attr("data-nil");
            self.maxLength = self.maxLength || jQuery(this).attr("data-max-length");
            // self.dirty = self.dirty || jQuery(this).attr("data-dirty");

            // adding callbacks for each instance
            self.callBackSuccess = self.callBackSuccess || jQuery(this).attr("data-call-back-success");
            self.callBackInit = self.callBackInit || jQuery(this).attr("data-call-back-init");
            self.callBackBind = self.callBackBind || jQuery(this).attr("data-call-back-bind");
            self.callBackNoChange = self.callBackNoChange || jQuery(this).attr("data-call-back-no-change");
        });
        // Try Rails-id based if parents did not explicitly supply something
        self.element.parents().each(function () {
            var res = this.id.match(/^(\w+)_(\d+)jQuery/i);
            if (res) {
                self.objectName = self.objectName || res[1];
            }
        });
        // Load own attributes (overrides all others)
        self.url = self.element.attr("data-url") || self.url || document.location.pathname;
        self.collection = self.element.attr("data-collection") || self.collection;
        self.formType = self.element.attr("data-type") || self.formtype || "input";
        self.objectName = self.element.attr("data-object") || self.objectName;
        self.attributeName = self.element.attr("data-attribute") || self.attributeName;
        self.activator = self.element.attr("data-activator") || self.element;
        self.nil = self.element.attr("data-nil") || self.nil || "-";
        self.maxLength = self.element.attr("data-max-length") || self.maxLength;
        // self.dirty = self.element.attr("data-dirty") || self.dirty;

        // adding callbacks for each instance
        self.callBackSuccess = self.callBackSuccess || jQuery(this).attr("data-call-back-success");
        self.callBackInit = self.callBackInit || jQuery(this).attr("data-call-back-init");
        self.callBackBind = self.callBackBind || jQuery(this).attr("data-call-back-bind");
        self.callBackNoChange = self.callBackNoChange || jQuery(this).attr("data-call-back-no-change");
        if (!self.element.attr("data-sanitize")) {
            self.sanitize = true;
        } else {
            self.sanitize = (self.element.attr("data-sanitize") == "true");
        }

        if ((self.formType == "select" || self.formType == "checkbox") && self.collection !== null)
        {
            self.values = jQuery.parseJSON(self.collection);
        }
       
       self.initNil();
        
    },
    bindForm: function () {
        this.activateForm = BestInPlaceEditor.forms[this.formType].activateForm;
        this.getValue = BestInPlaceEditor.forms[this.formType].getValue;
    },
    initNil: function () {
        if ((this.element.html() == "") | (this.element.html() == '<div class="data-nil">' + this.nil + '</div>'))
        {
            this.isNil = true
            this.element.html("<div class='data-nil'>" + this.nil + "</div>")
        }
        else
            this.isNil= false
    },
    getValue: function () {
        alert("The form was not properly initialized. getValue is unbound");
    },
    // Trim and Strips HTML from text
    sanitizeValue: function (s) {
        if (this.sanitize)
        {
            var tmp = document.createElement("DIV");
            tmp.innerHTML = s;
            s = jQuery.trim(tmp.textContent || tmp.innerText).replace(/"/g, '&quot;').replace(/'/g, '&#39;');
        } else
        {
            s = s.replace(/</g, '&lt;').replace(/>/g, '&gt;')
        }
        return jQuery.trim(s);
    },
    /* Generate the data sent in the POST request */
    requestData: function () {
        // To prevent xss attacks, a csrf token must be defined as a meta attribute
        csrf_token = jQuery('meta[name=csrf-token]').attr('content');
        csrf_param = jQuery('meta[name=csrf-param]').attr('content');
        var data = "_method=put";
        data += "&" + this.objectName + '[' + this.attributeName + ']=' + encodeURIComponent(this.getValue());
        if (csrf_param !== undefined && csrf_token !== undefined) {
            data += "&" + csrf_param + "=" + encodeURIComponent(csrf_token);
        }
        return data;
    },
    ajax: function (options) {
        options.url = this.url;
        options.beforeSend = function (xhr) {
            xhr.setRequestHeader("Accept", "application/json");
        };
        return jQuery.ajax(options);
    },
    // Handlers ////////////////////////////////////////////////////////////////

    loadSuccessCallback: function (data) {
        // console.log("data=(" + data + ")");
        if (data.length > 1) {
            dataJson = jQuery.parseJSON(data);
        }

        if ((this.element.html() == '<div class="data-nil">' + this.nil + '</div>') | (this.element.html() == ""))
        {
            this.isNil = true;
            this.element.html("<div class='data-nil'>" + this.nil + "</div>");
        } else
        {
            if (typeof (dataJson) != "undefined") {
                this.element.html(dataJson[this.objectName]);
            }
            if ((typeof (dataJson) != "undefined") && (typeof (dataJson["message"]) != "undefined") && (dataJson["message"].length > 0)) {
                setUpPurrNotifier("Warning", dataJson["message"]);
            }


        }

        // Binding back after being clicked
        jQuery(this.activator).bind('click', {
            editor: this
        }, this.clickHandler);
    },
    loadErrorCallback: function (request, error) {
 //       console.log("------>" );
 //       console.log(this.oldValue);
        if (this.oldValue != "" ) {
                    this.element.html(this.oldValue);
        }
        else 
            this.element.html("<div class='data-nil'>" + this.nil + "</div>");
       
        
        
        // Display all error messages from server side validation
        jQuery.each(jQuery.parseJSON(request.responseText), function (index, value) {
            var container = jQuery("<span class='flash-error'></span>").html(value);
            setUpPurrNotifier(index, value[0]);
            //           console.log("index:" + index + " value:" + value);

            //container.purr();
        });
        // Binding back after being clicked
        jQuery(this.activator).bind('click', {
            editor: this
        }, this.clickHandler);
    },
    clickHandler: function (event) {
        event.data.editor.activate();
        event.stopPropagation();
    },
    setHtmlAttributes: function () {
        var formField = this.element.find(this.formType);
        if (this.html_attrs) {
            var attrs = jQuery.parseJSON(this.html_attrs);
            for (var key in attrs) {
                formField.attr(key, attrs[key]);
            }
        }
    },
    // simple setters to set callbacks.
    setSuccessCallback: function (successCallbackFunction) {
        this.callBackSuccess = successCallbackFunction;
      //  this.callBackSuccess =  this.length > 0 ? successCallbackFunction : "";
    },
    setInitCallback: function (initCallbackFunction) {
        this.callBackInit = initCallbackFunction;
      //  this.callBackInit =   this.length > 0 ? initCallbackFunction : "";
    },
    setBindCallback: function (bindCallbackFunction) {
        this.callBackBind = bindCallbackFunction;
       // this.callBackBind =  this.length > 0 ? bindCallbackFunction : "";
    },
    setNoChangeCallback: function (noChangeCallbackFunction) {
        this.callBackNoChange = noChangeCallbackFunction;
//        this.callBackNoChange = this.length > 0 ? noChangeCallbackFunction : "";
    }
};
BestInPlaceEditor.forms = { 
    "date": {
        activateForm: function () {
            var that = this,
                    output = jQuery(document.createElement('form'))
                    .addClass('form_in_place')
                    .attr('action', 'javascript:void(0);')
                    .attr('style', 'display:inline'),
                    input_elt = jQuery(document.createElement('input'))
                    .attr('type', 'text')
                    .attr('class', 'best_in_place_adj')
                    .attr('name', this.attributeName)
                    .attr('value', this.sanitizeValue(this.oldValue));
            if (this.inner_class !== null) {
                input_elt.addClass(this.inner_class);
            }
            output.append(input_elt)

            this.element.html(output);
            BestInPlaceCallBackBind(this);
            // console.log("-------------------------------------------");
            // console.log("Testing callBackBind:");
            // console.log(this);
            // console.log(typeof this.callBackBind);

            if (typeof (this.callBackBind) == "function")
            {
                this.callBackBind(this);
            }

            this.setHtmlAttributes();
            this.element.find('input')[0].select();
            this.element.find("form").bind('submit', {editor: this}, BestInPlaceEditor.forms.input.submitHandler);
            this.element.find("input").bind('keyup', {editor: this}, BestInPlaceEditor.forms.input.keyupHandler);
            this.element.find('input')
                    .datepicker({
                        onClose: function () {
                            that.update();
                        }
                    })
                    .datepicker('show');
        },
        getValue: function () {
            return this.sanitizeValue(this.element.find("input").val());
        },
        submitHandler: function (event) {
            event.data.editor.update();
        },
        keyupHandler: function (event) {
            if (event.keyCode == 27) {
                event.data.editor.abort();
            }
        }
    },
//    "date" : {
//        activateForm : function() {
//            console.log("Date===>");
//
//            var output = 'Date: <form class="form_in_place" action="javascript:void(0)" style="display:inline;">';
//            output += '<input type="text" value="' + this.sanitizeValue(this.oldValue) + '" class="datepicker" ></form>';
//            
//            this.element.html(output);
//            this.element.find('input')[0].select();
//            this.element.find("form").bind('submit', {
//                editor: this
//            }, BestInPlaceEditor.forms.input.submitHandler);
//            this.element.find("input").bind('blur',   {
//                editor: this
//            }, BestInPlaceEditor.forms.input.inputBlurHandler);
//            this.element.find("input").bind('keyup', {
//                editor: this
//            }, BestInPlaceEditor.forms.input.keyupHandler);
//            //console.log("Date picker begin activated");
//
//            //console.log(jQuery( ".datepicker" ).datepicker());
//            
//            console.log(jQuery(".datepicker"));
//            jQuery(".datepicker").datepicker();
//            jQuery(".datepicker").datepicker('show');
//
//        },         
//
//
//        getValue :  function() {
//            return this.sanitizeValue(this.element.find("input").val());
//        },
//
//        inputBlurHandler : function(event) {
//            event.data.editor.update();
//        },
//
//        submitHandler : function(event) {
//            event.data.editor.update();
//        },
//
//        keyupHandler : function(event) {
//            if (event.keyCode == 27) {
//                event.data.editor.abort();
//            }
//        }
//    },
    "input": {
        activateForm: function () {
            // .hasClass("locked")
            //  console.log(jQuery(this.activator[0]).hasClass("locked"))
            if (jQuery(this.activator[0]).hasClass("locked")) {
                return;
            }
            var output = '<form class="form_in_place" action="javascript:void(0)" style="display:inline;">';
            output += '<input type="text"  class="best_in_place_adj" value="' + this.sanitizeValue(this.oldValue) + '"></form>';
            this.element.html(output);
            BestInPlaceCallBackBind(this);
            // console.log("-------------------------------------------");
            // console.log("Testing callBackBind:");
            // console.log(this);
            // console.log(typeof this.callBackBind);

            if (typeof (this.callBackBind) == "function")
            {
                this.callBackBind(this);
            }
            jQuery(this.element.find('input')).autoGrowInput();
            // added jqEasyCounter
            if (this.maxLength > 0) {
                jQuery(this.element.find('input')).jqEasyCounter({
                    'maxChars': this.maxLength,
                    'maxCharsWarning': this.maxLength - 5,
                    'msgFontColor': '#D3D3D3'
                });
            }
            ;
            if (this.element.find('input').width() < 5)
                this.element.find('input').width("5");
            //console.log(this.element.find('input'))

            this.element.find('input')[0].select();
            this.element.find("form").bind('submit', {
                editor: this
            }, BestInPlaceEditor.forms.input.submitHandler);
            this.element.find("input").bind('blur', {
                editor: this
            }, BestInPlaceEditor.forms.input.inputBlurHandler);
            this.element.find("input").bind('keyup', {
                editor: this
            }, BestInPlaceEditor.forms.input.keyupHandler);
            this.element.find("input").bind('keydown', {
                editor: this
            }, BestInPlaceEditor.forms.input.keydownHandler);
        },
        getValue: function () {
            return this.sanitizeValue(this.element.find("input").val());
        },
        inputBlurHandler: function (event) {
            event.data.editor.update();
        },
        submitHandler: function (event) {
            event.data.editor.update();
        },
        keydownHandler: function (event) {
            if (event.keyCode == 9) {
                event.preventDefault();
                // window.alert("keydown: " + event.keyCode);
                //  jQuery(this).parent().next().next().find(".best_in_place").trigger('click');
                //    jQuery(this).parent().parent().parent().next().next().find(".best_in_place").trigger('click');
                list = jQuery(".best_in_place");
                thisID = jQuery.inArray(jQuery(this).parent().parent()[0], list);
                if (event.shiftKey)
                {
                    // eval("jQuery(this).parent().parent().parent().prev().prev().prev().find('.best_in_place').trigger('click')")
                    //  console.log(jQuery(this).parent().parent().parent().prev().prev().prev().find(".best_in_place").trigger('click'));
                    //console.log(jQuery(this).parent().parent().parent().prev().prev().find(".best_in_place").trigger('click'));
                    // the wait function is a fix for a bug with safari
                    jQuery(this).focus();
                    wait(10);
                    jQuery(this).caretToEnd();
                    wait(10);
                    jQuery(list[thisID - 1]).trigger('click');
                    wait(10);
                } else
                {
                    //    console.log(jQuery(this).parent().parent());
                    //   console.log(jQuery(list[0]));
                    // console.log( thisID=jQuery.inArray(jQuery(this).parent().parent()[0],list)+1)
                    //  console.log(jQuery(list[thisID]).trigger('click'));
                    // console.log(jQuery(this));
                    jQuery(this).focus();
                    wait(10);
                    jQuery(this).caretToEnd();
                    wait(10);
                    jQuery(list[thisID + 1]).trigger('click');
                    wait(10);
                    //               console.log(jQuery(this).parent().parent().parent().next().next().next().find(".best_in_place").trigger('click'));
                    //               console.log( jQuery(this).parent().parent().parent().next().next().find(".best_in_place").trigger('click'));

                }

                //   jQuery(this).next('.best_in_place').activate();

            }

        },
        keyupHandler: function (event) {
            if (event.keyCode == 27) {
                event.data.editor.abort();
            }
        }
    },
    "select": {
        activateForm: function () {
            var output = "<form action='javascript:void(0)' style='display:inline;'><select>";
            var selected = "";
            var oldValue = this.oldValue;
            jQuery.each(this.values, function (index, value) {
                selected = (value[1] == oldValue ? "selected='selected'" : "");
                output += "<option value='" + value[0] + "' " + selected + ">" + value[1] + "</option>";
            });
            output += "</select></form>";
            this.element.html(output);
            this.element.find("select").bind('change', {
                editor: this
            }, BestInPlaceEditor.forms.select.blurHandler);
            this.element.find("select").bind('blur', {
                editor: this
            }, BestInPlaceEditor.forms.select.blurHandler);
            this.element.find("select").bind('keyup', {
                editor: this
            }, BestInPlaceEditor.forms.select.keyupHandler);
            this.element.find("select")[0].focus();
        },
        getValue: function () {
            return this.sanitizeValue(this.element.find("select").val());
        },
        blurHandler: function (event) {
            event.data.editor.update();
        },
        keyupHandler: function (event) {
            if (event.keyCode == 27)
            {
                event.data.editor.abort();
            }
        }
    },
    "checkbox": {
        activateForm: function () {
            var newValue = Boolean(this.oldValue != this.values[1]);
            var output = newValue ? this.values[1] : this.values[0];
            this.element.html(output);
            this.update();
        },
        getValue: function () {
            return Boolean(this.element.html() == this.values[1]);
        }
    },
    "textarea": {
        activateForm: function () {
            // grab width and height of text
            width = this.element.css('width');
            height = this.element.css('height');
            // construct the form
            var output = '<form action="javascript:void(0)" style="display:inline;"><textarea>';
            output += this.sanitizeValue(this.oldValue);
            output += '</textarea></form>';
            this.element.html(output);
            BestInPlaceCallBackBind(this);
            // console.log("-------------------------------------------");
            // console.log("Testing callBackBind:");
            // console.log(this);
            // console.log(typeof this.callBackBind);

            if (typeof (this.callBackBind) == "function")
            {
                this.callBackBind(this);
            }
            // set width and height of textarea
            jQuery(this.element.find("textarea")[0]).css({
                'min-width': width,
                'min-height': height
            });
            // added jqEasyCounter
            if (this.maxLength > 0) {
                jQuery(this.element.find('textarea')).jqEasyCounter({
                    'maxChars': this.maxLength,
                    'maxCharsWarning': this.maxLength - 5,
                    'msgFontColor': '#D3D3D3'
                });
            }
            ;
            jQuery(this.element.find("textarea")[0]).elastic();
            this.element.find("textarea")[0].focus();
            this.element.find("textarea").bind('blur', {
                editor: this
            }, BestInPlaceEditor.forms.textarea.blurHandler);
            this.element.find("textarea").bind('keyup', {
                editor: this
            }, BestInPlaceEditor.forms.textarea.keyupHandler);
        },
        getValue: function () {
            return this.sanitizeValue(this.element.find("textarea").val());
        },
        blurHandler: function (event) {
            event.data.editor.update();
        },
        keyupHandler: function (event) {
            if (event.keyCode == 27) {
                BestInPlaceEditor.forms.textarea.abort(event.data.editor);
            }
        },
        abort: function (editor) {
            if (confirm("Are you sure you want to discard your changes?")) {
                editor.abort();
            }
        }
    }
};
jQuery.fn.best_in_place = function () {
    this.each(function () {
        // Only initialize the editor if it is not already initialized!
        if (typeof jQuery(this).data('bestInPlaceEditor') == "undefined") {
            jQuery(this).data('bestInPlaceEditor', new BestInPlaceEditor(this));
        }
    });
    return this;
};
/**
 *	@name							Elastic
 *	@descripton						Elastic is Jquery plugin that grow and shrink your textareas automaticliy
 *	@version						1.6.5
 *	@requires						Jquery 1.2.6+
 *
 *	@author							Jan Jarfalk
 *	@author-email					jan.jarfalk@unwrongest.com
 *	@author-website					http://www.unwrongest.com
 *
 *	@licens							MIT License - http://www.opensource.org/licenses/mit-license.php
 */

(function (jQuery) {
    jQuery.fn.extend({
        elastic: function () {
            //	We will create a div clone of the textarea
            //	by copying these attributes from the textarea to the div.
            var mimics = [
                'paddingTop',
                'paddingRight',
                'paddingBottom',
                'paddingLeft',
                'fontSize',
                'lineHeight',
                'fontFamily',
                'width',
                'fontWeight'];
            return this.each(function () {

                // Elastic only works on textareas
                if (this.type != 'textarea') {
                    return false;
                }

                var jQuerytextarea = jQuery(this),
                        jQuerytwin = jQuery('<div />').css({
                    'position': 'absolute',
                    'display': 'none',
                    'word-wrap': 'break-word'
                }),
                        lineHeight = parseInt(jQuerytextarea.css('line-height'), 10) || parseInt(jQuerytextarea.css('font-size'), '10'),
                        minheight = parseInt(jQuerytextarea.css('height'), 10) || lineHeight * 3,
                        maxheight = parseInt(jQuerytextarea.css('max-height'), 10) || Number.MAX_VALUE,
                        goalheight = 0,
                        i = 0;
                // Opera returns max-height of -1 if not set
                if (maxheight < 0) {
                    maxheight = Number.MAX_VALUE;
                }

                // Append the twin to the DOM
                // We are going to meassure the height of this, not the textarea.
                jQuerytwin.appendTo(jQuerytextarea.parent());
                // Copy the essential styles (mimics) from the textarea to the twin
                var i = mimics.length;
                while (i--) {
                    jQuerytwin.css(mimics[i].toString(), jQuerytextarea.css(mimics[i].toString()));
                }


                // Sets a given height and overflow state on the textarea
                function setHeightAndOverflow(height, overflow) {
                    curratedHeight = Math.floor(parseInt(height, 10));
                    if (jQuerytextarea.height() != curratedHeight) {
                        jQuerytextarea.css({
                            'height': curratedHeight + 'px',
                            'overflow': overflow
                        });
                    }
                }


                // This function will update the height of the textarea if necessary
                function update() {

                    // Get curated content from the textarea.
                    var textareaContent = jQuerytextarea.val().replace(/&/g, '&amp;').replace(/  /g, '&nbsp;').replace(/<|>/g, '&gt;').replace(/\n/g, '<br />');
                    // Compare curated content with curated twin.
                    var twinContent = jQuerytwin.html().replace(/<br>/ig, '<br />');
                    if (textareaContent + '&nbsp;' != twinContent) {

                        // Add an extra white space so new rows are added when you are at the end of a row.
                        jQuerytwin.html(textareaContent + '&nbsp;');
                        // Change textarea height if twin plus the height of one line differs more than 3 pixel from textarea height
                        if (Math.abs(jQuerytwin.height() + lineHeight - jQuerytextarea.height()) > 3) {

                            var goalheight = jQuerytwin.height() + lineHeight;
                            if (goalheight >= maxheight) {
                                setHeightAndOverflow(maxheight, 'auto');
                            } else if (goalheight <= minheight) {
                                setHeightAndOverflow(minheight, 'hidden');
                            } else {
                                setHeightAndOverflow(goalheight, 'hidden');
                            }

                        }

                    }

                }

                // Hide scrollbars
                jQuerytextarea.css({
                    'overflow': 'hidden'
                });
                // Update textarea size on keyup, change, cut and paste
                jQuerytextarea.bind('keyup change cut paste', function () {
                    update();
                });
                // Compact textarea on blur
                // Lets animate this....
                jQuerytextarea.bind('blur', function () {
                    if (jQuerytwin.height() < maxheight) {
                        if (jQuerytwin.height() > minheight) {
                            jQuerytextarea.height(jQuerytwin.height());
                        } else {
                            jQuerytextarea.height(minheight);
                        }
                    }
                });
                // And this line is to catch the browser paste event
                jQuery(document).on('input paste', jQuerytextarea, function (e) {
                    setTimeout(update, 250);
                    return;
                });
                // Run update once when elastic is initialized
                update();
            });
        }
    });
})(jQuery);
