// --------------------------------- Settings ---------------------------------
var $bucketSelect = $("#bucket-select");

// --------------------------------- Buckets: ---------------------------------
var allBuckets = [
  { id: '1', text: 'random' },
  { id: '2', text: 'Neighborhood Events' },
  { id: '3', text: 'Telegraph Clients' },
  { id: '4', text: 'TyPo' },
  { id: '5', text: 'SmallBrewpub' },
  { id: '6', text: 'Davis Street Espresso' },
  { id: '7', text: 'Gardening' },
  { id: '8', text: 'Cocktails' },
  { id: '9', text: 'Camping Hiking' },
  { id: '10', text: 'Patagonia Trip' },
  { id: '11', text: 'oakcliff' }
];

// ------------------------------- Initialize: --------------------------------
// $bucketSelect.select2({
//   data: allBuckets,
//   tags: true,
//   // selectOnClose: true,
//   tokenSeparators: [','],
//   allowClear: false,
// });

// ----------------------------------------------------------------------------
// $bucketSelect.select2({
//   data: allBuckets,
//   tags: true,
//   tokenSeparators: [','],
//   allowClear: false,
// }).on("change", function() { 
//   // $bucketSelect.select2("select2:close");
//   console.log('change');
// });



// Works:
// .on("select2:close", function() { 
// alert("closed");
// });

// Kinda there:
// .on("change", function() { 
//   $bucketSelect.select2("select2:close");
//   console.log('change');
// });
// $bucketSelect.on("change", function(evt) { 
//    $bucketSelect.select2().trigger("select2:close");
// });

//    $('select2-dropdown').hide();




// ---------------------- Pre-populate buckets example: -----------------------
// $bucketSelect.val(["9","6", "10"]).trigger("change");