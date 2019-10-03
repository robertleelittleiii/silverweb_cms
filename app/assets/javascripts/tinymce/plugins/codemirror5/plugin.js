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
test_editor = "";
codeEditor = "";
tinymce.PluginManager.add('codemirror5', function (editor, url) {
    test_editor = editor;
    var setContent = function (editor, html) {
        editor.focus();
        editor.undoManager.transact(function () {
            editor.setContent(html);
        });
        editor.selection.setCursorLocation();
        editor.nodeChanged();
    };
    var getContent = function (editor) {
        return editor.getContent({source_view: true});
    };
    var Content = {
        setContent: setContent,
        getContent: getContent
    };

    function showSourceEditor() {
        editor.focus()
        editor.selection.collapse(true)

        // Insert caret marker
        if (editor.settings.codemirror.saveCursorPosition) {
            editor.selection.setContent('<span style="display: none;" class="CmCaReT">&#x0;</span>')
        }

        var codemirrorWidth = 800
        if (editor.settings.codemirror.width) {
            codemirrorWidth = editor.settings.codemirror.width
        }

        var codemirrorHeight = 550
        if (editor.settings.codemirror.width) {
            codemirrorHeight = editor.settings.codemirror.height
        }

        var buttonsConfig = (tinymce.majorVersion < 5)
                ? [
                    {
                        text: 'Ok',
                        subtype: 'primary',
                        onclick: function () {
                            var doc = document.querySelectorAll('.mce-container-body>iframe')[0]
                            doc.contentWindow.submit()
                            win.close()
                        }
                    },
                    {
                        text: 'Cancel',
                        onclick: 'close'
                    }
                ]
                : [
                    {
                        type: 'custom',
                        text: 'Ok',
                        name: 'codemirrorOk',
                        primary: true
                    },
                    {
                        type: 'cancel',
                        text: 'Cancel',
                        name: 'codemirrorCancel'
                    }
                ]

        var config = {
            title: 'HTML source code',
            url: url + '/source.html',
            width: codemirrorWidth,
            height: codemirrorHeight,
            resizable: true,
            maximizable: true,
            fullScreen: editor.settings.codemirror.fullscreen,
            saveCursorPosition: false,
            buttons: buttonsConfig
        }

        if (tinymce.majorVersion >= 5) {
            config.onAction = function (dialogApi, actionData) {
                if (actionData.name === 'codemirrorOk') {
                    alert("this is a test");
                    codeEditor.save();
                    codeEditor.toTextArea();
                    content = $(codeEditor.getTextArea()).val();
                    Content.setContent(editor, content); //api.getData().code
                    api.close();
//                    var doc = document.querySelectorAll('.tox-dialog__body-iframe iframe')[0]
//                    doc.contentWindow.submit()
//                    win.close()
                }
            }
        }

        var win = (tinymce.majorVersion < 5)
                ? editor.windowManager.open(config)
                : editor.windowManager.openUrl(config)

//        if (editor.settings.codemirror.fullscreen) {
//            win.fullscreen(true)
//        }

        requireCss("codemirror.css");
        requireCss("tinymce/plugins/codemirror/plugin.css")
        requireCss("codemirror/docs/docs.css");

        require("codemirror/lib/codemirror.js");
        require("codemirror/mode/htmlmixed/htmlmixed.js");
        require("codemirror/mode/css/css.js");
        require("codemirror/mode/xml/xml.js");
        require("codemirror/mode/javascript/javascript.js");
        require("codemirror/lib/formating.js")
    }

    function showDialog() {
        var editorContent = Content.getContent(editor);
        editor.windowManager.open({
            title: 'Source Code',
            size: 'large',
            body: {
                type: 'panel',
                items: [{
                        type: 'textarea',
                        name: 'code'
                    }]
            },
            buttons: [
                {
                    type: 'cancel',
                    name: 'cancel',
                    text: 'Cancel'
                },
                {
                    type: 'submit',
                    name: 'save',
                    text: 'Save',
                    primary: true
                }
            ],
            initialData: {code: editorContent},
            onSubmit: function (api) {

                codeEditor.save();
                codeEditor.toTextArea();
                content = $(codeEditor.getTextArea()).val();
                Content.setContent(editor, content); //api.getData().code
                api.close();
            }
        });

//        var win = editor.windowManager.open({
//            title: "Source code",
//            body: {
//                type: 'textbox',
//                name: 'code',
//                multiline: true,
//                minWidth: editor.getParam("code_dialog_width", 800),
//                minHeight: editor.getParam("code_dialog_height", Math.min(tinymce.DOM.getViewPort().h - 200, 500)),
//                spellcheck: false,
//                style: 'direction: ltr; text-align: left'
//            },
//            onSubmit: function (e) {
//                // We get a lovely "Wrong document" error in IE 11 if we
//                // don't move the focus to the editor before creating an undo
//                // transation since it tries to make a bookmark for the current selection
//                codeEditor.save();
//                codeEditor.toTextArea();
//                content = $(codeEditor.getTextArea()).val();
//
//                editor.focus();
//                editor.undoManager.transact(function () {
//                    editor.setContent(content);
//                    //             editor.setContent(e.data.code);
//                });
//
//                editor.selection.setCursorLocation();
//                editor.nodeChanged();
//            }
//        });



        // Gecko has a major performance issue with textarea
        // contents so we need to set it when all reflows are done
        $("textarea.tox-textarea").text(editor.getContent({source_view: true}).split(">").join(">\n"));
        requireCss("codemirror.css");
        requireCss("tinymce/plugins/codemirror/plugin.css")
        requireCss("codemirror/docs/docs.css");

        require("codemirror/lib/codemirror.js");
        require("codemirror/mode/htmlmixed/htmlmixed.js");
        require("codemirror/mode/css/css.js");
        require("codemirror/mode/xml/xml.js");
        require("codemirror/mode/javascript/javascript.js");
        require("codemirror/lib/formating.js")

    }



    function getSelectedRange(codeEditor) {
        return {from: codeEditor.getCursor(true), to: codeEditor.getCursor(false)};
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
        // make sure there aren't any extra skin.min.css files loaded on page
        // cause by a bug in the loader for tinymce.

        var skin_links = $('link[href*="tinymce/skins/lightgray/skin.min.css"]')
        var number_of_skins_loaded = skin_links.size();
        if (number_of_skins_loaded > 1) { // remove any extras since they mess up the codemirror tool.
            for (i = 1; i < number_of_skins_loaded; i++) {
                skin_links[i].remove();
            }
        }

        codeEditor = CodeMirror.fromTextArea(
                $("iframe").last().contents().find("textarea#code").get(0),
                {
                    mode: {name: "htmlmixed"},
                    tabMode: "indent",
                    lineNumbers: true,
                    height: 400,
                    width: 400
                });

        CodeMirror.commands["selectAll"](codeEditor);

        autoFormatSelection(codeEditor);
        codeEditor.refresh();
//     setTimeout(function(){ 
//         
//    },500); 
    }

    editor.addCommand("CodeMirror5", showDialog);

    editor.ui.registry.addButton('code', {
        icon: 'code',
        tooltip: 'Source code',
        onAction: showDialog
    });

//    editor.ui.registry.addNestedMenuItem('Tools', {
//        text: 'My nested menu item',
//        getSubmenuItems: function () {
//            return [
//                {
//                    type: 'menuitem',
//                    text: 'codeMirror Editor',
//                    onAction: function () {
//                        showDialog();
//                        //  initCodeMirror();
//                        //wait(1000);
//                        //setTimeout(initCodeMirror(),3000);
//                        setTimeout(function () {
//                            initCodeMirror();
//                        }, 500);
//                    }
//                }
//            ];
//        }
//    });

    editor.ui.registry.addMenuItem('code', {
        icon: 'code',
        text: 'codeMirror Editor',
        context: 'tools',
        onAction: function () {
            // showDialog();
            showSourceEditor()
            //  initCodeMirror();
            //wait(1000);
            //setTimeout(initCodeMirror(),3000);
            setTimeout(function () {
                initCodeMirror();
            }, 500);



        }
    });
});