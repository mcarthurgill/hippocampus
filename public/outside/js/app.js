// ================================= Skrollr =================================
if ($(window).width() > 768) {
   jQuery(window).load(function($) {
	  var s = skrollr.init({forceHeight: false});
	});
} else {$('body').addClass('noSkrollr');}

// ---------------------------------- Ready -----------------------------------
$(document).ready(function(){
	$('body').addClass('ready');
	//================================== Steps ===================================
	var continuousElements = document.getElementsByClassName('step')
	  for (var i = 0; i < continuousElements.length; i++) {
	    new Waypoint({
	      element: continuousElements[i],
	      handler: function() {
	        $(this.element).addClass('transit');
	      },
	      offset: '80px'
	    })
	  }

	// ================================== Video ==================================
	$('a[data-rel^=lightcase]').lightcase({
		overlayOpacity: .86,
	    video: {
	      width : 768,
	      height : 432,
	    }
	  });

	// ================================== Tabs ===================================
	// Content Visibility
	$('.tab_content').hide();
	$('.tab_content.current').show();
	
	$('ul.tabs.first li').click(function(){
		// Toggle Content
		var tab_id = $(this).attr('data-tab');
		$('ul.tabs.first li').removeClass('current');
		$(this).addClass('current');
		$('.content.first .tab_content').fadeOut(400).promise().done(function(){
		    $("#"+tab_id).fadeIn(400);	
		});

	})

	$('ul.tabs.second li').click(function(){
		// Toggle Content
		var tab_id = $(this).attr('data-tab');
		$('ul.tabs.second li').removeClass('current');
		$(this).addClass('current');
		$('.content.second .tab_content').fadeOut(400).promise().done(function(){
		    $("#"+tab_id).fadeIn(400);	
		});

	})

	// =============================== Intro Hover ===============================
	$('#actionHover01').hover(function(){
		$(this).parent().parent().parent().toggleClass('hoverShift');
	})

})