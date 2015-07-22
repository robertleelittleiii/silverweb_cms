tinymce.PluginManager.add('image_library', function(editor, url) {
    global_editor_hold = editor;
    
    // Add a button that opens a window
    editor.addButton('image_library', {
        icon: 'image-librarys',
        tooltip: 'Insert/add image from library',
        onclick: function() {
            // Open window
            editor.windowManager.open({
                title: 'Image Libary',
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
    
    

    // Adds a menu item to the tools menu
    editor.addMenuItem('Image libary', {
        text: 'Image Libary',
        context: 'tools',
        onclick: function() {
            // Open window with a specific url
            editor.windowManager.open({
                title: 'Image Libary',
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
});