tinymce.PluginManager.add('imagelibrary2', function (editor, url) {
    global_editor_hold = editor;

    // Add a button that opens a window

        editor.ui.registry.addButton('imagelibrary2', {
            icon: 'image',
            tooltip: 'Insert/add image from library',
            onAction: function () {
                // Open window

                tinymce.activeEditor.windowManager.openUrl({
                    title: 'Image Library',
                    url: '/image_library/image_list?as_window=true',
                    width: 875,
                    height: 600,
                    buttons: [{
                        name: 'Close',
                        text: 'Close',
                        onclick: 'close',
                        type: 'cancel',
                        primary: true,
                    }]
                });
            }
        });


    // Adds a menu item to the tools menu


        editor.ui.registry.addMenuItem('imagelibrary2', {
            text: 'Image Library',
            context: 'tools',
            icon: 'image',
            onAction: function () {
                // Open window with a specific url
                tinymce.activeEditor.windowManager.openUrl({
                    title: 'Image Library',
                    url: '/image_library/image_list?as_window=true',
                    width: 875,
                    height: 600,
                    buttons: [{
                        name: 'Close',
                        text: 'Close',
                        onclick: 'close',
                        type: 'cancel',
                        primary: true,
                    }]
                });
            }
        });
});