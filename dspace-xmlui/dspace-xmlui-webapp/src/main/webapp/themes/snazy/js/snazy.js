(function() {
  $(document).ready(function() {
    $('ul#file_list').addClass('js').removeClass('no-js');
    return $('ul#file_list .file-entry .slide-arrow').click(function() {
      var fentry, fv, fvc;
      fentry = $(this).parent(".file-entry");
      if ($(this).hasClass("show")) {
        $(this).removeClass("show");
        $(this).addClass("hide");
        $(this).find("span.showhide").html("Hide file");
        fv = fentry.find(".file-view");
        fvc = fv.find(".file-view-container");
        return fv.slideDown();
      } else {
        $(this).removeClass("hide");
        $(this).addClass("show");
        $(this).find("span.showhide").html("Show file");
        fv = fentry.find(".file-view");
        fvc = fv.find(".file-view-container");
        return fv.slideUp();
      }
    });
  });
}).call(this);
