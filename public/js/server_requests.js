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
      contentType: 'application/js;',
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
  console.log(response);
  GetToServer("/users")
}

function errorReplaceAllItems(response) {
  console.log("****ERROR****");
  console.log(response);
}