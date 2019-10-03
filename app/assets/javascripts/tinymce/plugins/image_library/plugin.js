tinymce.PluginManager.add('image_library', function(editor, url) {
    global_editor_hold = editor;
    
    // Add a button that opens a window
    editor.ui.registry.addToggleButton('image_library', {
        icon: 'image',
        tooltip: 'Insert/add image from library',
        onAction: function() {
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
    
    

    // Adds a menu item to the tools menu
    editor.ui.registry.addMenuItem('image_library', {
        text: 'Image Library',
        icon: 'image',
        onAction: function() {
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
});