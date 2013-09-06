$ ->
  $('.badge-codes-toggle').on 'click', ->
    $('.badge-codes-block').toggle()

  $('body').on 'click', '.sync-now', ->
    $(this).find('i').addClass('icon-spin')
