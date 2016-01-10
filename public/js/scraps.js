$.each(bucketNames, function(index, value) {
  // $("#testBox").append("<div class='mongol'>" + value + '</div>');
  // console.log("<div class='mongol'>" + value + '</div>');
  console.log('<a class="label" href="#">'+ value +  '<span class="remove"></span></a>');
});

// --------------------------- Shift Enter Key ----------------------------
// if (e.keyCode == 13 && e.shiftKey)
// {
//     console.log('shift enter key');
// }




// if ($rapidInput.text().length > 0) {
    // $(".thoughts-list").append("<li>"+newStatus+"</li>");
    // $('#test-mde-output').append("<li>"+defaultEditor.options.previewRender(defaultEditor.value())+"</li>");

// Function to handle 'Enter':

$.fn.enterKey = function (fnc) {
    return this.each(function () {
        $(this).keypress(function (ev) {
            var keycode = (ev.keyCode ? ev.keyCode : ev.which);
            if (keycode == '13') {
                fnc.call(this, ev);
            }
        })
    })
}


//      // ----------------------------- Unused stuff ------------------------------
    //      // $('#test-mde-output').append("<li>"+defaultEditor.value()+"</li>");
    //  // var simplemde = new SimpleMDE();
    //  // defaultEditor.codemirror.on("change", function(){
    //  //     console.log(defaultEditor.value());
    //  // });

    //  // If content exists, don't show placeholder
    //  if (defaultEditor.value()) {
    //      $('.CodeMirror').addClass('placeholderOff');

    //  } else {
    //      // Else, if no content, show placeholder till user types:
    //      defaultEditor.codemirror.on("change", function(){
    //          // console.log(defaultEditor.value());
    //          $('.CodeMirror').addClass('placeholderOff');
    //      });
    //  };
    // }


    
    // ----------------------- Rapid Thought Input Editor ------------------------
    // var defaultEditorID = document.getElementById("rapid-thought-input");
    // if (defaultEditorID !== null) {
    //   var defaultEditor = new SimpleMDE({
    //       element: defaultEditorID,
    //       status: false,
    //       toolbar: false,
    //       spellChecker: false,
    //       indentWithTabs: false,
    //       autosave:false,
    //       autoDownloadFontAwesome: false,
    //       autofocus:true,
    //   });
        
    //      // Testing: on enter, push content to test output field
    //      defaultEditor.codemirror.on("keyHandled", function(editor, event){
    //     if(event == "Enter") {
    //          $('#test-mde-output').append("<li>"+defaultEditor.options.previewRender(defaultEditor.value())+"</li>");
    
    //     }
    //  });
        
    