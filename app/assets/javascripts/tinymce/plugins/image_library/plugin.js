tinymce.PluginManager.add('image_library', function (editor, url) {
    global_editor_hold = editor;

    // Add a button that opens a window
    if (tinymce.majorVersion < 5) {
        editor.addButton('image', {
            icon: 'image',
            tooltip: 'Insert/add image from library',
            onclick: function () {
                // Open window

                editor.windowManager.open({
                    title: 'Image Library',
                    url: '/image_library/image_list?as_window=true',
                    width: 875,
                    height: 600,
                    buttons: [{
                            text: 'Close',
                            onclick: 'close'
                        }]
                });
            }
        });

    } else
    {

        editor.ui.registry.addToggleButton('image_library', {
            icon: 'image',
            tooltip: 'Insert/add image from library',
            onAction: function () {
                // Open window

                editor.windowManager.openUrl({
                    title: 'Image Library',
                    url: '/image_library/image_list?as_window=true',
                    width: 875,
                    height: 600,
                    buttons: [{
                            type: 'cancel',
                            text: 'Close',
                            name: 'close'
                        }]
                });
            }
        });
    }


    // Adds a menu item to the tools menu


    if (tinymce.majorVersion < 5) {
        editor.addMenuItem('Image library', {
            text: 'Image Library',
            context: 'tools',
            onclick: function () {
                // Open window with a specific url
                editor.windowManager.open({
                    title: 'Image Library',
                    url: '/image_library/image_list?as_window=true',
                    width: 875,
                    height: 600,
                    buttons: [{
                            text: 'Close',
                            onclick: 'close'
                        }]
                });
            }
        });
    } else
    {
        editor.ui.registry.addMenuItem('image_library', {
            text: 'Image Library',
            icon: 'image',
            onAction: function () {
                // Open window with a specific url
                editor.windowManager.openUrl({
                    title: 'Image Library',
                    url: '/image_library/image_list?as_window=true',
                    width: 875,
                    height: 600,
                    buttons: [{
                            type: 'cancel',
                            text: 'Close',
                            name: 'close'
                        }]
                });
            }
        });


    }
});