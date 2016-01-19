

// ================================ Doc Ready =================================
$(document).ready(function() {
	
	$(document).foundation();

	// ------------------------------ Scroll Bottom ------------------------------
	var scrollBtm = document.getElementById("sBtm");
	if (scrollBtm !== null) {
		scrollBtm.scrollIntoView();
		scrollBtm.scrollIntoView(false);
		scrollBtm.scrollIntoView({block: "end"});
		scrollBtm.scrollIntoView({block: "end", behavior: "smooth"});
	}

	// ------------------------- Add Thought Area Editor -------------------------
	var defaultEditorID = document.getElementById("default-editor");
	if (defaultEditorID !== null) {
	  var defaultEditor = new SimpleMDE({
	      element: defaultEditorID,
	      status: false,
	      toolbar: false,
	      spellChecker: false,
	      indentWithTabs: false,
	      autosave:false,
	      autoDownloadFontAwesome: false,
	      autofocus:true,
	  });

		// If content exists, don't show placeholder
		if (defaultEditor.value()) {
			$('.CodeMirror').addClass('placeholderOff');

		} else {
			// Else, if no content, show placeholder till user types:
			defaultEditor.codemirror.on("change", function(){
			    // console.log(defaultEditor.value());
			    $('.CodeMirror').addClass('placeholderOff');
			});
		};
	}

	// --------------------------------- Submit Item -----------------------------
	$("#saveButton").on("click", function(e){
		if ($("#new_item").length) {
			$("#new_item").submit(); 
		} else if ($(".edit_item").length) {
			$(".edit_item").submit(); 
		}
	});


	// --------------------------------- Nice.js ---------------------------------
	$('.nice').niceSelect();

	// -------------- Bucket Sort Select: Update #current-selection --------------
	$('#sort-by-select').on('change', function() {
		var currentSelected = $(this).find(':selected').data('selection')

        $('#current-selection').html(currentSelected)
        // console.log(currentSelected);
    });

	// ------------------------------ Bucket Search ------------------------------
	$('#bucket-search-input').bind('blur focus', function(){
	    $(this).toggleClass('expanded');
	});
	// ------------------------------- Main Search -------------------------------
	$('.main-search .search-field').bind('blur focus', function(){
	    $(this).parent().toggleClass('expanded');
	});

	// ----------------------------- Delete Buckets ------------------------------
	var mainContent =  '.main-content'
	var bucketLabel =  '.label .remove'
	$(mainContent).on('click', bucketLabel, function(e){
		e.preventDefault();
		$(this).parent().addClass('hide').delay(500).queue(function(next){
		    $(this).hide()
		    next();
		});
	});

	// ---------------------------- Toggle Side Menu -----------------------------
	var sideMenu = $('.side-menu_mbl')
	var shiftItems = $('.main-content, .main-secondary-menus-mbl-wrap, .thought-menu')

	$('.close-side-menu_mbl, .trigger-side-menu_mbl').on("click", function(){  //click function
		if(sideMenu.is('.visible')) { 
			sideMenu.removeClass('visible');
			shiftItems.removeClass('side-menu_mbl-is-visible');
		} 
		else {
			sideMenu.addClass('visible');
			shiftItems.addClass('side-menu_mbl-is-visible');
		}
	});



	// ----------------- Thought View: Bucket Select Visibility ------------------
	var $toggleBucketSelect = $("#toggle-bucket-select");
	var $BucketWrap = $(".buckets");
	$toggleBucketSelect.on('click', function(e){
		e.preventDefault();
		$BucketWrap.toggleClass('showBuckets').removeClass('init-showBuckets')
	});


	// -------------------------------- Calendar ---------------------------------
	var dropdown = $('#nudge-menu-1, #nudge-menu-2');
    
    // do things (e.g. allow user to click places)
    
	$(function($) {
		var dateAsArray = $("#hidden-reminder-date-field").val().split("-"); 
		var dateDefault = new Date(parseInt(dateAsArray[0]), parseInt(dateAsArray[1] - 1), parseInt(dateAsArray[2])); 
	  $("#calendar").datepicker({
    	showOtherMonths: true,
		selectOtherMonths: true,
		defaultDate: dateDefault,
	    onSelect: function(dateText) {
	      display(this.value);
	    },
	    onChangeMonthYear: function () {
	    	dropdown.addClass('prevent-hide');
	    	$('#overlay').addClass('on');
	    }
	  })

	  function display(msg) {
	    $("#outputDate").html(msg);
	    setReminderDate(msg);
	  }
	});
	$('#overlay').click(function() {
		dropdown.removeClass('prevent-hide');
		$(this).removeClass('on');
	});

	function setReminderDate(dateString) {
		var date = new Date(dateString);
		$("#hidden-reminder-date-field").val(date);
	}

	// -------------------------- Calendar Settings ---------------------------
    var $nudgeFrequencyOption = $('select#calendar-frequency-option')
    var $nudgeFrequencyOutput = $('#outputFrequency')
    var $nudgeDateOutput = $('#outputDate')
    
    // -------------------- Calendar: Set Frequency Output --------------------
    $nudgeFrequencyOption.on('change', function() {
      $nudgeFrequencyOutput.html(this.value)
    });

    // ------------------------ Calendar: Remove Nudge ------------------------
    $('#remove-calendar-nudge').on('click', function(){
      $('#calendar').datepicker('setDate', null);
      $nudgeFrequencyOutput.html(null);
      $nudgeDateOutput.html(null);
      setReminderDate("01/01/1970");
      $('#calendar-frequency-option option').each(function(){
      	this.selected = (this.value == "once");
      });
    });

	// ---------------------------------- Star -----------------------------------
	$("a.star").click(function(e) {
	  e.preventDefault();
	  if ($(this).hasClass("starred")) {
	    $(this).removeClass("starred").addClass("unstarred");
	  } else if ($(this).hasClass("unstarred")) {
	    $(this).removeClass("unstarred").addClass("starred");
	  } else {
	    $(this).addClass("starred");
	  }
	});

	// ---------------------------------- Tipso ----------------------------------
	$('.main-menu .tipso').tipso({
	    tooltipHover: true,
	    background: '#4A4A4A',
	    color: '#fffff',
	    position: 'left',
	    width: '108',
	    offsetY: -2,
	    offsetX: -8,
	  });
	$('.img-tipso').tipso({
	  useTitle : false,
	  background: '#4A4A4A',
      color: '#fffff',
      width: '120',
	  position: 'right',
	});

	// ---------------------------------- Hide -----------------------------------


	var mainContent =  '.main-content'
	var triggerHide =  '.triggerHide'
	$(mainContent).on('click', triggerHide, function(e){
		e.preventDefault();
		$(this).parent().addClass('fade').delay(500).queue(function(next){
		    $(this).hide()
		    next();
		});
	});
	
	
	// ================================ All Good =================================
	console.log('All good.')
});  