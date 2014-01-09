
reloadChart = (event, data) ->
  $('#charts').html(data.responseText)
  $('.chart-links li.active').removeClass('active')
  $(event.target).parent('li').addClass('active')
  #console.log($(event.target).parent('li'))


jQuery ->
  $('.chart-links a').bind('ajax:complete',reloadChart)
  $('.chart-links a').first().click()