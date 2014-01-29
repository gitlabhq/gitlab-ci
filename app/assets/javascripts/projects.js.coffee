$(document).on 'click', '.badge-codes-toggle', ->
  $('.badge-codes-block').toggle()

$(document).on 'click', '.sync-now', ->
  $(this).find('i').addClass('icon-spin')
