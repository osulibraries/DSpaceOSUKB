$(document).ready ->
  $('ul#file_list').addClass('js').removeClass('no-js')
  $('ul#file_list .file-entry .slide-arrow').click ->
    fentry = $(@).parent ".file-entry"
    if $(@).hasClass "show"
      $(@).removeClass "show"
      $(@).addClass "hide"
      $(@).find("span.showhide").html "Hide file"
      fv = fentry.find(".file-view")
      fvc = fv.find(".file-view-container")
      fv.slideDown()
    else
      $(@).removeClass "hide"
      $(@).addClass "show"
      $(@).find("span.showhide").html "Show file"
      fv = fentry.find(".file-view")
      fvc = fv.find(".file-view-container")
      fv.slideUp()
