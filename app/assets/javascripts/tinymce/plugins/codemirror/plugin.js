/**
 * plugin.js
 *
 * Copyright, Moxiecode Systems AB
 * Released under LGPL License.
 *
 * License: http://www.tinymce.com/license
 * Contributing: http://www.tinymce.com/contributing
 */

/*global tinymce:true */

tinymce.PluginManager.add('codemirror', function (editor) {
    function showDialog() {
        var win = editor.windowManager.open({
            title: "Source code",
            body: {
                type: 'textbox',
                name: 'code',
                multiline: true,
                minWidth: editor.getParam("code_dialog_width", 800),
                minHeight: editor.getParam("code_dialog_height", Math.min(tinymce.DOM.getViewPort().h - 200, 500)),
                spellcheck: false,
                style: 'direction: ltr; text-align: left'
            },
            onSubmit: function (e) {
                // We get a lovely "Wrong document" error in IE 11 if we
                // don't move the focus to the editor before creating an undo
                // transation since it tries to make a bookmark for the current selection
                codeEditor.save();
                codeEditor.toTextArea();
                content = $(codeEditor.getTextArea()).val();
                
                editor.focus();
                editor.undoManager.transact(function () {
                    editor.setContent(content);
       //             editor.setContent(e.data.code);
                });

                editor.selection.setCursorLocation();
                editor.nodeChanged();
            }
        });



        // Gecko has a major performance issue with textarea
        // contents so we need to set it when all reflows are done
        win.find('#code').value(editor.getContent({source_view: true}).split(">").join(">\n"));

        requireCss("codemirror.css");
        requireCss("tinymce/plugins/codemirror/plugin.css")
        // requireCss("codemirror/docs/docs.css");

        require("codemirror/lib/codemirror.js");
        require("codemirror/mode/htmlmixed/htmlmixed.js");
        require("codemirror/mode/css/css.js");
        require("codemirror/mode/xml/xml.js");
        require("codemirror/mode/javascript/javascript.js");
        require("codemirror/lib/formating.js")
        
    }
    
    
            
      function getSelectedRange(codeEditor) {
        return { from: codeEditor.getCursor(true), to: codeEditor.getCursor(false) };
      }
      
      function autoFormatSelection(codeEditor) {
        var range = getSelectedRange(codeEditor);
        codeEditor.autoFormatRange(range.from, range.to);
      }
      
      function commentSelection(isComment, codeEditor) {
        var range = getSelectedRange();
        codeEditor.commentRange(isComment, range.from, range.to);
      }      
    
    function initCodeMirror() {
        codeEditor = CodeMirror.fromTextArea(
                $("textarea.mce-textbox").get(0),
                {
                    mode: {name: "htmlmixed"},
                    tabMode: "indent",
                    lineNumbers: true,
                    height:500
                });  
                
                CodeMirror.commands["selectAll"](codeEditor);
                
         autoFormatSelection(codeEditor);
         
//     setTimeout(function(){ 
//         
//    },500); 
    }
    
    editor.addCommand("CodeMirror", showDialog);

    editor.addButton('codemirror', {
        icon: 'code',
        tooltip: 'Source code',
        onclick: showDialog
    });

    editor.addMenuItem('codemirror', {
        icon: 'code',
        text: 'codeMirror code',
        context: 'tools',
        onclick: function () {
            showDialog();
           //  initCodeMirror();
            //wait(1000);
            //setTimeout(initCodeMirror(),3000);
           setTimeout(function(){initCodeMirror(); },500);  
            
              
            
        }
    });
});