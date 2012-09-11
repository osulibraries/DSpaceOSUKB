/**
 * @author Jason Roy for CompareNetworks Inc.
 * Thanks to mikejbond for suggested udaptes
 *
 * Version 1.1
 * Copyright (c) 2009 CompareNetworks Inc.
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/mit-license.php
 *
 */
(function($)
{

    // Private variables
    
    var _options = {}
    var _container = {}
    var _breadCrumbElements = {}
    var _autoIntervalArray = [];
    var _easingEquation;
    
    // Public functions
    
    jQuery.fn.jBreadCrumb = function(options)
    {
        _options = $.extend({}, $.fn.jBreadCrumb.defaults, options);
        
        return this.each(function()
        {
            _container = $(this);
            setupBreadCrumb();
        });
        
    }
    
    // Private functions

    function setupBreadCrumb()
    {
        //Check if easing plugin exists. If it doesn't, use "swing"
        if(typeof(jQuery.easing) == 'object')
        {
            _easingEquation = 'easeOutQuart'
        }
        else
        {
            _easingEquation = 'swing'
        }
    
        //The reference object containing all of the breadcrumb elements
        _breadCrumbElements = jQuery(_container).find('li');
        
        //Keep it from overflowing in ie6 & 7
        jQuery(_container).find('ul').wrap('<div style="overflow:hidden; position:relative;  width: ' + jQuery(_container).css("width") + ';"><div>');
        //Set an arbitrary width width to avoid float drop on the animation
        jQuery(_container).find('ul').width(5000);
        
        //If the breadcrumb contains nothing, don't do anything
        if (_breadCrumbElements.length > 0) 
        {
            jQuery(_breadCrumbElements[_breadCrumbElements.length - 1]).addClass('last');
            jQuery(_breadCrumbElements[0]).addClass('first');
            
            //If the breadcrumb object length is long enough, compress.
            
            if (_breadCrumbElements.length > _options.minimumCompressionElements) 
            {
                compressBreadCrumb();
            }
        }
    }



    function compressBreadCrumb()
    {
        var itemsToRemove = _breadCrumbElements.length - 1;
        
        // We compress only elements determined by the formula setting below
        
        //TODO : Make this smarter, it's only checking the final elements length.  It could also check the amount of elements.
        jQuery(_breadCrumbElements[_breadCrumbElements.length - 1]).css(
        {
            background: 'none'
        });
        
        $(_breadCrumbElements).each(function(i, listElement)
        {
            if (i > _options.beginingElementsToLeaveOpen && i < itemsToRemove) 
            {
                jQuery(listElement).find('a').wrap('<span></span>').width(jQuery(listElement).find('a').width() + 10);
                
                // Add the overlay png.
                jQuery(listElement).append(jQuery('<div class="' + _options.overlayClass + '"></div>').css(
                {
                    display: 'block'
                })).css(
                {
                    background: 'none'
                });
                if (isIE6OrLess()) 
                {
                    fixPNG(jQuery(listElement).find('.' + _options.overlayClass).css(
                    {
                        width: '20px',
                        right: "-1px"
                    }));
                }
                var options = 
                {
                    id: i,
                    width: jQuery(listElement).width(),
                    listElement: jQuery(listElement).find('span'),
                    isAnimating: false,
                    element: jQuery(listElement).find('span')
                
                }
                jQuery(listElement).bind('mouseover', options, expandBreadCrumb).bind('mouseout', options, shrinkBreadCrumb);
                jQuery(listElement).find('a').unbind('mouseover', expandBreadCrumb).unbind('mouseout', shrinkBreadCrumb);

                //Also bind the mouse effect to onFocus
                jQuery(listElement).find('a').bind('focus', options, expandBreadCrumb).bind('blur', options, shrinkBreadCrumb);

                listElement.autoInterval = setInterval(function()
                {
                    clearInterval(listElement.autoInterval);
                    jQuery(listElement).find('span').animate(
                    {
                        width: _options.previewWidth
                    }, _options.timeInitialCollapse, _options.easing);
                }, (150 * (i - 2)));
                
            }
        });
        
    }
    
    function expandBreadCrumb(e)
    {
        var elementID = e.data.id;
        var originalWidth = e.data.width;
        jQuery(e.data.element).stop();
        jQuery(e.data.element).animate(
        {
            width: originalWidth
        }, 
        {
            duration: _options.timeExpansionAnimation,
            easing: _options.easing,
            queue: false
        });
        return false;
    }
    
    function shrinkBreadCrumb(e)
    {
        var elementID = e.data.id;
        jQuery(e.data.element).stop();
        jQuery(e.data.element).animate(
        {
            width: _options.previewWidth
        }, 
        {
            duration: _options.timeCompressionAnimation,
            easing: _options.easing,
            queue: false
        });
        return false;
    }
    
    function isIE6OrLess()
    {
        var isIE6 = $.browser.msie && /MSIE\s(5\.5|6\.)/.test(navigator.userAgent);
        return isIE6;
    }
    // Fix The Overlay for IE6
    function fixPNG(element)
    {
        var image;
        if (jQuery(element).is('img')) 
        {
            image = jQuery(element).attr('src');
        }
        else 
        {
            image = $(element).css('backgroundImage');
            image.match(/^url\(["']?(.*\.png)["']?\)$/i);
            image = RegExp.$1;
        }
        $(element).css(
        {
            'backgroundImage': 'none',
            'filter': "progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true, sizingMethod=scale, src='" + image + "')"
        });
    }
    
    // Public global variables
    
    jQuery.fn.jBreadCrumb.defaults = 
    {
        maxFinalElementLength: 250,
        minFinalElementLength: 200,
        minimumCompressionElements: 0,
        endElementsToLeaveOpen: 0,
        beginingElementsToLeaveOpen: 0,
        timeExpansionAnimation: 600,
        timeCompressionAnimation: 900,
        timeInitialCollapse: 0,
        easing: _easingEquation,
        overlayClass: 'chevronOverlay',
        previewWidth: 40
    }
    
})(jQuery);
