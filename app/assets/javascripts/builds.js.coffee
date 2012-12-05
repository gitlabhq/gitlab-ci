$(document).ready ->
  $("#autoscroll-button").bind "click", ->
    state = $(this).data("state")
    if "enabled" is state
      $(this).data "state", "disabled"
      $(this).text "enable autoscroll"
    else
      $(this).data "state", "enabled"
      $(this).text "disable autoscroll"
