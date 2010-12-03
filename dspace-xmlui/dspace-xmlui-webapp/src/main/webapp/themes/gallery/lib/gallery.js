
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
        var serviceImg = new Object();
        serviceImg.size = 0;

        for ( var i=0; i<imageJpegArray.length; i++)
        {
            if (imageJpegArray[i].size < MAX_SERVICE_IMG_SIZE && (imageJpegArray[i].size > serviceImg.size))
            {
                serviceImg = imageJpegArray[i];
            }
        }

        if (serviceImg.size > 0)
        {

            var caption;    //Show an image caption. Either short description or title.
            if(serviceImg.caption.length > 0)
            {
                 caption = serviceImg.caption;
            } else {
                caption = serviceImg.itemTitle;
            }

            var html =  "<a href='"+serviceImg.url+"' class='thickbox' title=\"" + caption + "\"><img src =\""+serviceImg.url+"\" alt='Image of: "+ serviceImg.title +"' title=\""+ serviceImg.itemTitle + "\"";
            html+= " width='"+ZOOMABLE_IMG_WIDTH+"'></img></a>";



            html += "<br/><span>" + caption + "</span>";

            $("#photos").prepend(html);
            serviceImgUrl = serviceImg.url;
        }

    }
}