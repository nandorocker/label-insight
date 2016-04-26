(function(){

   // click on mobile nav to toggle
   if($(window).width() < 768) {
   		$('#nav_top').click(function() {
   			$('#nav_collapse').slideToggle()
   		});
   	}

})(jQuery)