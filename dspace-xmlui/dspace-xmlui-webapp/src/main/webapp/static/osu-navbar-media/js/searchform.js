/**
 * @author Mike Brittain
 * see http://www.alistapart.com/articles/makingcompactformsmoreaccessible
 */
function initOverLabels () {
  if (!document.getElementById) return;   

  var labels, id, field;

  // Set focus and blur handlers to hide and show 
  // LABELs with 'overlabel' class names.
  labels = document.getElementsByTagName('label');
  for (var i = 0; i < labels.length; i++) {
  
    if (labels[i].className == 'overlabel') {

      // Skip labels that do not have a named association
      // with another field.
      id = labels[i].htmlFor || labels[i].getAttribute('for');
      if (!id || !(field = document.getElementById(id))) {
        continue;
      }

      // Change the applied class to hover the label 
      // over the form field.
    
    var agent = navigator.userAgent.toLowerCase();
    
    if (agent.indexOf("msie") != -1) {
      labels[i].className = 'overlabel-apply-win';
    }
    
    else {
      labels[i].className = 'overlabel-apply';
    }

      // Hide any fields having an initial value.
      if (field.value !== '') {
        hideLabel(field.getAttribute('id'), true);
      }
      // Set handlers to show and hide labels.
      field.onfocus = function () {
        hideLabel(this.getAttribute('id'), true);
      };
      field.onblur = function () {
        if (this.value === '') {
          hideLabel(this.getAttribute('id'), false);
        }
      };

      // Handle clicks to LABEL elements (for Safari).
      labels[i].onclick = function () {
        var id, field;
        id = this.getAttribute('for');
        if (id && (field = document.getElementById(id))) {
          field.focus();
        }
      };

    }
  }
};

function hideLabel (field_id, hide) {
  var field_for;
  var labels = document.getElementsByTagName('label');
  for (var i = 0; i < labels.length; i++) {
    field_for = labels[i].htmlFor || labels[i].getAttribute('for');
    if (field_for == field_id) {
      labels[i].style.textIndent = (hide) ? '-1000px' : '0px';
      return true;
    }
  }
}

/*
 * addLoadListener function by Cameron Adams and James Edwards from a technique by Simon Willison
 */ 
function addLoadListener(fn)
{
  if (typeof window.addEventListener != 'undefined')
  {
    window.addEventListener('load', fn, false);
  }
  else if (typeof document.addEventListener != 'undefined')
  {
    document.addEventListener('load', fn, false);
  }
  else if (typeof window.attachEvent != 'undefined')
  {
    window.attachEvent('onload', fn);
  }
  else
  {
    var oldfn = window.onload;
    if (typeof window.onload != 'function')
    {
      window.onload = fn;
    }
    else
    {
      window.onload = function()
      {
        oldfn();
        fn();
      };
    }
  }
}

addLoadListener(initOverLabels);