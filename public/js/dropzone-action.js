// -------------------------------- Dropzone ---------------------------------
new Dropzone(document.body, { // Make the whole body a dropzone
  url: "/upload/url", // Set the url
  previewsContainer: "#previews", 
  clickable: "#upload-assets"
});