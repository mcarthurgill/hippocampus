function PostToServer(url, parameters, successCallback, errorCallback) {
  $.ajax({
      type: 'POST',
      url: url,
      data: JSON.stringify(parameters),
      contentType: 'application/json;',
      dataType: 'json',
      success: function(response){
        successCallback(response); 
      },
      error: function(response){
        errorCallback(response); 
      }
  });
}

function GetToServer(url, parameters, successCallback, errorCallback) {
  if (parameters == null) {
    $.ajax({
        type: 'GET',
        url: url,
        contentType: 'application/json;',
        dataType: 'json',
        success: function(response){
          successCallback(response); 
        },
        error: function(response){
          errorCallback(response); 
        }
    });  
  } else {
    $.ajax({
        type: 'GET',
        url: url,
        data: JSON.stringify(parameters),
        contentType: 'application/json;',
        dataType: 'json',
        success: function(response){
          successCallback(response); 
        },
        error: function(response){
          errorCallback(response); 
        }
    });
  };
  
}

function replaceAllItems(response) {
  console.log("****SUCCESS!!!****");
  url = '/users/' + response.user_id + '/items.js'
  GetToServer(url, null, doNothing, doNothing)
}

function errorReplaceAllItems(response) {
  console.log("****ERROR****");
  console.log(response);
}

function doNothing(response){
  console.log("do nothing");
  console.log(response);
  html = $.parseHTML(response);
  $("#item-list").html(html);
}