/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var tinymce, // Reference to TinyMCE
        editor, // Reference to TinyMCE editor
        codemirror, // CodeMirror instance
        chr = 0, // Unused utf-8 character, placeholder for cursor
        isMac = /macintosh|mac os/i.test(navigator.userAgent),
        CMsettings;  // CodeMirror settings



$(document).ready(function () {
// Initialise (before load)
    "use strict";

    tinymce = parent.tinymce;
    editor = tinymce.activeEditor;
    var i, userSettings = editor.settings.codemirror ? editor.settings.codemirror : {};
    CMsettings = {
        path: userSettings.path || 'codemirror-4.8',
        indentOnInit: userSettings.indentOnInit || false,
        disableFilesMerge: userSettings.disableFilesMerge || false,
        config: {// Default config
            mode: 'htmlmixed',
            theme: 'default',
            lineNumbers: true,
            lineWrapping: true,
            indentUnit: 2,
            tabSize: 2,
            indentWithTabs: true,
            matchBrackets: true,
            saveCursorPosition: false,
            styleActiveLine: true
        },
        jsFiles: [// Default JS files
            'lib/codemirror.js',
            'addon/edit/matchbrackets.js',
            'mode/xml/xml.js',
            'mode/javascript/javascript.js',
            'mode/css/css.js',
            'mode/htmlmixed/htmlmixed.js',
            'addon/dialog/dialog.js',
            'addon/search/searchcursor.js',
            'addon/search/search.js',
            'addon/selection/active-line.js'
        ],
        cssFiles: [// Default CSS files
            'lib/codemirror.css',
            'addon/dialog/dialog.css'
        ]
    };

    if (userSettings.fullscreen) {
        CMsettings.jsFiles.push('addon/display/fullscreen.js');
        CMsettings.cssFiles.push('addon/display/fullscreen.css');
    }

    if (CMsettings.disableFilesMerge) {
        if (
                Array.isArray(userSettings.jsFiles) &&
                Array.isArray(userSettings.cssFiles) &&
                (userSettings.jsFiles.length > 0) &&
                (userSettings.cssFiles.length > 0)
                ) {
            CMsettings.jsFiles = []
            CMsettings.cssFiles = []
        } else {
            if (console) {
                console.error('Codemirror plugin: jsFiles and cssFiles must be specified if disableFilesMerge is set to true')
                console.warn('Codemirror plugin: ignoring disableFilesMerge')
            }
        }
    }

    // Merge config
    for (i in userSettings.config) {
        CMsettings.config[i] = userSettings.config[i];
    }


    // Merge jsFiles
    for (i in userSettings.jsFiles) {
        if (!inArray(userSettings.jsFiles[i], CMsettings.jsFiles)) {
            CMsettings.jsFiles.push(userSettings.jsFiles[i]);
        }
    }

    // Merge cssFiles
    for (i in userSettings.cssFiles) {
        if (!inArray(userSettings.cssFiles[i], CMsettings.cssFiles)) {
            CMsettings.cssFiles.push(userSettings.cssFiles[i]);
        }
    }

    // Add trailing slash to path
    if (!/\/$/.test(CMsettings.path)) {
        CMsettings.path += '/';
    }

    // Write stylesheets
    /* for (i = 0; i < CMsettings.cssFiles.length; i++) {
     document.write('<li'+'nk rel="stylesheet" type="text/css" href="' + CMsettings.path + CMsettings.cssFiles[i] + '" />');
     }
     // Write JS source files
     for (i = 0; i < CMsettings.jsFiles.length; i++) {
     document.write('<scr'+'ipt type="text/javascript" src="' + CMsettings.path + CMsettings.jsFiles[i] + '"></scr'+'ipt>');
     }
     */

    // Borrowed from codemirror.js themeChanged function. Sets the theme's class names to the html element.
    // Without this, the background color outside of the codemirror wrapper element remains white.
    // [TMP] commented temporary, cause JS error: Uncaught TypeError: Cannot read property 'replace' of undefined
    if (CMsettings.config.theme) {
        document.documentElement.className += CMsettings.config.theme.replace(/(^|\s)\s*/g, " cm-s-");
    }

    window.onload = start;

});



function inArray(key, arr)
{
    "use strict";
    arr = '|' + arr.join('|') + '|';
    return arr.indexOf('|' + key + '|') != -1;
}


//
// javascript loader asycn using ajax
//
//
function require(script) {
    var theUrl = "/assets/" + script;
    // var theTimeStamp = getRailsTimeStamp();

    // $("script[src='/javascripts/ie_fixes.js?1361329086']")

    //  if (!$("script[src^='" + theUrl + "']").length) {
    // alert("loaded");
    //

    $.ajax({
        url: "/site/load_asset",
        data: {path: script},
        dataType: "text",
        async: false, // <-- this is the key
        success: function (data) {

            if (data != "") {
                var javascriptLink = $("<script>").attr({
                    type: "text/javascript",
                    src: data
                });

                // handle frame based cloud system
                if ($('iframe.iframe-application').length) {
                    if (!$('iframe.iframe-application').contents().find('head script[src$="' + data + '"]').length) {
                        $("head").append(javascriptLink);
                    }

                } else if (!$('script[src="' + data + '"]').length) {
                    $("head").append(javascriptLink);
                }
            }
            // all good...
        },
        fail: function () {
            console.warn("Could not load script " + script);
        }
    });
}

//
// css loader async using ajax
//
//
function requireCss(cssFile) {
    // var theTimeStamp = getRailsTimeStamp();
    // var theTimeStamp = getRailsTimeStamp();
    // if (cssFile.charAt(0) == "/") {
    var href = "/assets/" + cssFile;
    //alert("loaded");
    $.ajax({
        url: "/site/load_asset",
        data: {path: cssFile},
        dataType: 'text',
        success: function (data) {
            if (data != "") {
                var cssLink = $("<link>").attr({
                    rel: "stylesheet",
                    type: "text/css",
                    href: data
                });
                // $('link[href$="'+ data +'"]').length
                if ($('iframe.iframe-application').length) {
                    if (!$('iframe.iframe-application').contents().find('head link[href$="' + data + '"]').length) {
                        $("head").append(cssLink);
                    }
                } else if (!$('link[href$="' + data + '"]').length) {
                    $("head").append(cssLink);
                }
            }
            //your callback
        },
        fail: function () {
            console.warn("Could not load script " + script);
        }
    });

}

function start()
{// Initialise (on load)
    "use strict";

    requireCss("codemirror.css");
    requireCss("tinymce/plugins/codemirror/plugin.css")
    requireCss("codemirror/docs/docs.css");

    require("codemirror/lib/codemirror.js");
    require("codemirror/mode/htmlmixed/htmlmixed.js");
    require("codemirror/mode/css/css.js");
    require("codemirror/mode/xml/xml.js");
    require("codemirror/mode/javascript/javascript.js");
    require("codemirror/lib/formating.js")
    require("codemirror/addon/search/searchcursor.js")
    require("codemirror/addon/search/search.js")

//   requireCss("codmirror/lib/codemirror.css");
//    // requireCss("codmirror/addon/dialog/dialog.css");
//    // requireCss("tinymce/plugins/codemirror/plugin.css")
//    // requireCss("codemirror/docs/docs.css");
//    require("codemirror/lib/codemirror.js");
//    require("codemirror/addon/edit/matchbrackets.js");
//    require("codemirror/mode/xml/xml.js");
//    require("codemirror/mode/javascript/javascript.js");
//    require("codemirror/mode/css/css.js");
//    require("codemirror/mode/htmlmixed/htmlmixed.js");
//    require("codemirror/mode/javascript/javascript.js");
//    require("codemirror/lib/formating.js")
//    require("codemirror/addon/search/searchcursor.js")
//    require("codemirror/addon/search/search.js")


    if (typeof (window.CodeMirror) !== 'function') {
        alert('CodeMirror not found in "' + CMsettings.path + '", aborting...');
        return;
    }

    // Create legend for keyboard shortcuts for find & replace:
    var head = parent.document.querySelectorAll((tinymce.majorVersion < 5) ? '.mce-foot' : '.tox-dialog__footer')[0],
            div = parent.document.createElement('div'),
            td1 = '<td style="font-size:11px;background:#777;color:#fff;padding:0 4px">',
            td2 = '<td style="font-size:11px;padding-right:5px">';
    div.innerHTML = '<table cellspacing="0" cellpadding="0" style="border-spacing:4px"><tr>' + td1 + (isMac ? '&#8984;-F' : 'Ctrl-F</td>') + td2 + tinymce.translate('Start search') + '</td>' + td1 + (isMac ? '&#8984;-G' : 'Ctrl-G') + '</td>' + td2 + tinymce.translate('Find next') + '</td>' + td1 + (isMac ? '&#8984;-Alt-F' : 'Shift-Ctrl-F') + '</td>' + td2 + tinymce.translate('Find previous') + '</td></tr>' + '<tr>' + td1 + (isMac ? '&#8984;-Alt-F' : 'Shift-Ctrl-F') + '</td>' + td2 + tinymce.translate('Replace') + '</td>' + td1 + (isMac ? 'Shift-&#8984;-Alt-F' : 'Shift-Ctrl-R') + '</td>' + td2 + tinymce.translate('Replace all') + '</td></tr></table>';
    div.style.position = 'absolute';
    div.style.left = div.style.bottom = '5px';
    head.appendChild(div);

    // Set CodeMirror cursor and bookmark to same position as cursor was in TinyMCE:
    var html = editor.getContent({source_view: true});

    // [FIX] #6 z-index issue with table panel and source code dialog
    //	editor.selection.getBookmark();

    html = html.replace(/<span\s+style="display: none;"\s+class="CmCaReT"([^>]*)>([^<]*)<\/span>/gm, String.fromCharCode(chr));
    editor.dom.remove(editor.dom.select('.CmCaReT'));

    // Hide TinyMCE toolbar panels, [FIX] #6 z-index issue with table panel and source code dialog
    // https://github.com/christiaan/tinymce-codemirror/issues/6
    tinymce.each(editor.contextToolbars, function (toolbar) {
        if (toolbar.panel) {
            toolbar.panel.hide();
        }
    });

    CodeMirror.defineInitHook(function (inst)
    {
        // Move cursor to correct position:
        inst.focus();
        var cursor = inst.getSearchCursor(String.fromCharCode(chr), false);
        if (cursor.findNext()) {
            inst.setCursor(cursor.to());
            cursor.replace('');
        }

        // Indent all code, if so requested:
        if (editor.settings.codemirror.indentOnInit) {
            var last = inst.lineCount();
            inst.operation(function () {
                for (var i = 0; i < last; ++i) {
                    inst.indentLine(i);
                }
            });
        }
    });

    CMsettings.config.value = html //.split(">").join(">\n").split("<").join("\n<").split("\n\n").join("\n");

    // Instantiante CodeMirror:
    setTimeout(function () {
        codemirror = CodeMirror(document.body, CMsettings.config);
        codemirror.isDirty = false;
        codemirror.on('change', function (inst) {
            inst.isDirty = true;
        });
    }, 500);

}

function findDepth(haystack, needle)
{
    "use strict";

    var idx = haystack.indexOf(needle), depth = 0, x;
    for (x = idx - 1; x >= 0; x--) {
        switch (haystack.charAt(x)) {
            case '<':
                depth--;
                break;
            case '>':
                depth++;
                break;
            case '&':
                depth++;
                break;
        }
    }
    return depth;
}

// This function is called by plugin.js, when user clicks 'Ok' button
function submit()
{
    "use strict";

    var cc = '&#x0;', isDirty = codemirror.isDirty, doc = codemirror.doc;

    if (doc.somethingSelected()) {
        // Clear selection:
        doc.setCursor(doc.getCursor());
    }

    // Insert cursor placeholder (&#x0;)
    doc.replaceSelection(cc);

    var pos = codemirror.getCursor(),
            curLineHTML = doc.getLine(pos.line);

    if (findDepth(curLineHTML, cc) !== 0) {
        // Cursor is inside a <tag>, don't set cursor:
        curLineHTML = curLineHTML.replace(cc, '');
        doc.replaceRange(curLineHTML, CodeMirror.Pos(pos.line, 0), CodeMirror.Pos(pos.line));
    }

    // Submit HTML to TinyMCE:
    // [FIX] Cursor position inside JS, style or &nbps;
    // Workaround to fix cursor position if inside script tag
    var code = codemirror.getValue();
    
    console.log(code.replace(cc + '<p>',''));
    
    editor.setContent(code.replace(cc + '<p>',''));
    
//    if (code.search(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi) !== -1 || code.search(/<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>/gi) !== -1)
//    {
//        editor.setContent(codemirror.getValue().replace(cc + "<p>", ''));
//    } else
//    {
//        editor.setContent(codemirror.getValue().replace(cc, '<span id="CmCaReT"></span>'));
//    }

    editor.isNotDirty = !isDirty;
    if (isDirty) {
        editor.nodeChanged();
    }

    // Set cursor:
    var el = editor.dom.select('span#CmCaReT')[0];
    if (el) {
        editor.selection.scrollIntoView(el);
        editor.selection.setCursorLocation(el, 0);
        editor.dom.remove(el);
    }
}