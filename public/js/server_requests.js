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
  $.ajax({
      type: 'GET',
      url: url,
      data: JSON.stringify(parameters),
      contentType: 'application/javascript;',
      dataType: 'json',
      success: function(response){
        successCallback(response); 
      },
      error: function(response){
        errorCallback(response); 
      }
  });
}

function replaceAllItems(response) {
  console.log("****SUCCESS!!!****");
  url = '/users/' + response.user_id + '/items.js'
  GetToServer(url, { user_id: response.user_id.toString() }, doNothing, doNothing)
}

function errorReplaceAllItems(response) {
  console.log("****ERROR****");
  console.log(response);
}

function doNothing(response){
  console.log("do nothing");
  console.log(response);
}