$(document).ready ->
  $('ul#file_list .file-entry .slide-arrow').click =>
    fentry = $(this).parent ".file-entry"
    if $(this).hasClass "show"
      $(this).removeClass "show"
      fentry.find(".file-view").show()
      $(this).addClass "hide"
    else
      $(this).addClass "show"
      fentry.find(".file-view").hide()
      $(this).removeClass "hide"
