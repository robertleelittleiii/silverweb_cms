tinymce.PluginManager.add('image_library', function(editor, url) {
    // Add a button that opens a window
    editor.addButton('image_library', {
        icon: 'image',
        tooltip: 'Insert/add image from library',
        onclick: function() {
            // Open window
            editor.windowManager.open({
                title: 'Image Library',
                body: [
                    {type: 'textbox', name: 'title', label: 'Title'}
                ],
                onsubmit: function(e) {
                    // Insert content when the window form is submitted
                    editor.insertContent('Title: ' + e.data.title);
                }
            });
        }
    });

    // Adds a menu item to the tools menu
    editor.addMenuItem('Image libary', {
        text: 'Image Libaray',
        context: 'tools',
        onclick: function() {
            // Open window with a specific url
            editor.windowManager.open({
                title: 'Image Libary',
                url: '/image_library/image_list',
                width: 800,
                height: 600,
                buttons: [{
                    text: 'Close',
                    onclick: 'close'
                }]
            });
        }
    });
});