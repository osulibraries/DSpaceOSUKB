
/* VARIABLES

/*  
Used on the gallery page.
Records all ids assigned to items in order to initialize popups in the gallery display 
*/
var itemids = Array();

/* 
Used on the individual item display page.
Not currently used, but is populated and intended for later development.

An array of Javascript object of JPEGs in the file, each with the 
properties size and url, as in 
	o.size
	o.url
The app can then make user of these as necessary. For example, 
could be used to display a service image if it was under 1 MB, etc 
*/
var imageJpegArray = Array();

/* 
Convenience access to the service image's url
*/
var serviceImgUrl = '';


/**
* JQuery initialization routine 
*/
$(document).ready(function() {
    /* bds: no longer used
	initGalleryPopups();
    */
	initZoomableImage();
	
	// initialize the about popup
        /* bds: no longer used
	$("a#about").fancybox({
		'hideOnContentClick':false
	});
        */
});

/**
* Initializes popups on the gallery view page
*/
/* bds: no longer used
function initGalleryPopups() {
	for (var i=0; i != itemids.length; i++) { 
		var sel = "a#anchor" + itemids[i]; 
		$(sel).fancybox({ 'hideOnContentClick': false }); 
		sel = "a#image" + itemids[i]; 
		$(sel).fancybox({ 'hideOnContentClick': false }); 
	} 
}
*/
/**
* If there is a JPEG image less than MAX_SERVICE_IMG_SIZE, 
* set the largest image found as the service image
* and display it as a zoomable image
*/
function initZoomableImage() {
	
	if (imageJpegArray.length >0)  {
	
		var serviceImg = new Object();
		serviceImg.size = 0;
		
		for ( var i=0; i<imageJpegArray.length; i++) {
			if (imageJpegArray[i].size < MAX_SERVICE_IMG_SIZE && 
				( imageJpegArray[i].size > serviceImg.size))  {
				serviceImg = imageJpegArray[i];
			}
		}
		
		if (serviceImg.size > 0) {
			var html =  "<img src ='"+serviceImg.url+"' alt='zoomable image' onmouseover='TJPzoom(this);' width='"+ZOOMABLE_IMG_WIDTH+"'>";
			html+=	"</img>"
			$("#image-zoom-panel").prepend(html);
			
			serviceImgUrl = serviceImg.url;
			

		}
		
	}
}


function showAbout() {
	$("#gallery-about").load(ABOUT_PAGE_URL);
}