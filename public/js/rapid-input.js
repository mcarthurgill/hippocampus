// -------------------------------- Settings --------------------------------
// Rapid Input Field:
var rapidInput = $('#rapid-thought-input');
// Scroll to Bottom:
var scrollBtm = document.getElementById("sBtm");  

// Init Autosize:
autosize($('#rapid-thought-input'));

// ---------------------------------- Events ----------------------------------
rapidInput.keydown(function(e){
    // ------------------------------ Enter Key -------------------------------
    if (e.keyCode == 13 && !e.shiftKey)
    { 

      console.log('enter key');
      e.preventDefault(); // Don't allow line break | test: console.log('enter key');

      // ---------------------------- If content: -----------------------------
      if (rapidInput.val()) {

        var userThought = rapidInput.val();
      
        $(".thoughts-list").append("<li>"+userThought+"</li>"); 
        PostToServer('/items', {item: {'message': userThought, 'input_method': 'web'}, origin:'web'}, replaceItems); 
        // -------------------------- Reset/Clear ---------------------------
        rapidInput.val("");
        rapidInput.css("height","50px");

        //-------------------------------- Btm --------------------------------
        scrollBtm.scrollIntoView();
        scrollBtm.scrollIntoView(false);
        scrollBtm.scrollIntoView({block: "end"});
        scrollBtm.scrollIntoView({block: "end", behavior: "smooth"});
      }   
    }
    // --------------------------- Shift Enter Key ----------------------------
    if (e.keyCode == 13 && e.shiftKey)
    {
        console.log('shift enter key');

    }
});


function PostToServer(url, parameters, successCallback) {
  $.ajax({
      type: 'POST',
      url: url,
      data: JSON.stringify(parameters),
      contentType: 'application/json;',
      dataType: 'json',
      success: successCallback,
      error: function(xhr, textStatus, errorThrown) {
          console.log('error');
      }
  });
}

function replaceItems() {
  console.log("****BOOOOOM*****");
  
}