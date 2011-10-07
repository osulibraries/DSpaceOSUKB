(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $(document).ready(function() {
    return $('ul#file_list .file-entry .slide-arrow').click(__bind(function() {
      var fentry;
      fentry = $(this).parent(".file-entry");
      if ($(this).hasClass("show")) {
        $(this).removeClass("show");
        fentry.find(".file-view").show();
        return $(this).addClass("hide");
      } else {
        $(this).addClass("show");
        fentry.find(".file-view").hide();
        return $(this).removeClass("hide");
      }
    }, this));
  });
}).call(this);
