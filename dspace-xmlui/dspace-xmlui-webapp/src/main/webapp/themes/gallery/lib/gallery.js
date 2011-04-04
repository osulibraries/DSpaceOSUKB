
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
$(document).ready(function()
{
    initZoomableImage();

    //$("div.right img").jScale({ls:'200px'});
    initjQueryTools();
});

/**
* If there is a JPEG image less than MAX_SERVICE_IMG_SIZE,
* set the largest image found as the service image
* and display it as a zoomable image
*/
function initZoomableImage()
{
    if (imageJpegArray.length >0)
    {
        var viewPort = "<div id=\"image_wrap\"><a id=\"anchor\" href=\"#\" class=\"thickbox\"><img class=\"central_image\" src=\"" + THEME_PATH + "images/blank.gif\" /></a></div>";
        var totalHtml = viewPort;

        var containHtml = "<div class=\"scrollable\"><div class=\"items\"><div>";
        totalHtml += containHtml;

        for ( var i=0; i<imageJpegArray.length; i++)
        {
            totalHtml +=processImage(imageJpegArray[i]);
        }

        var tailHtml = "</div></div></div>";
        totalHtml += tailHtml;
        $("#photos").prepend(totalHtml);
        if(imageJpegArray.length == 1) {
            $('div.scrollable').css('display', 'none');

        }
    }
}

function processImage(serviceImg)
{
    return "<img src =\""+serviceImg.url+"\" alt=\""+ serviceImg.title +"\" title=\""+ serviceImg.itemTitle + "\"/>";
}



function initjQueryTools () {

$(".scrollable").scrollable();

$(".items img").click(function() {

	// see if same thumb is being clicked
	if ($(this).hasClass("active")) { return; }

	// Currently assuming that thumbnail and full image use same url.
        var clickedImage = $(this);
	var url = clickedImage.attr("src");

	// get handle to element that wraps the image and make it semi-transparent
	var wrap = $("#image_wrap").fadeTo("medium", 0.5);

	var img = new Image();

	// call this function after it's loaded
	img.onload = function() {
		// make wrapper fully visible
		wrap.fadeTo("fast", 1);


		// change the image
		wrap.find("img").attr("src", url);

                //wrap.find('img').jScale({ls:'670px'});
		$('#anchor').attr("href", url);
                $('#anchor').attr("title", clickedImage.attr("title") + "<br/>Download: <a href=\""+url+"\">" + clickedImage.attr("alt") + "</a>" );


	};

	// begin loading the image
	img.src = url;

	// activate item
	$(".items img").removeClass("active");
	$(this).addClass("active");

// when page loads simulate a "click" on the first image
}).filter(":first").click();
}
