$(document).ready ->
  $("#autoscroll-button_top").bind "click", ->
    state = $(this).data("state")
    if "enabled" is state
      $(this).data "state", "disabled"
      $(this).text "enable autoscroll"
      $("#autoscroll-button_bot").data "state", "disabled"
      $("#autoscroll-button_bot").text "enable autoscroll"
    else
      $(this).data "state", "enabled"
      $(this).text "disable autoscroll"
      $("#autoscroll-button_bot").data "state", "enabled"
      $("#autoscroll-button_bot").text "disable autoscroll"
  $("#autoscroll-button_bot").bind "click", ->
    state = $(this).data("state")
    if "enabled" is state
      $(this).data "state", "disabled"
      $(this).text "enable autoscroll"
      $("#autoscroll-button_top").data "state", "disabled"
      $("#autoscroll-button_top").text "enable autoscroll"
    else
      $(this).data "state", "enabled"
      $(this).text "disable autoscroll"
      $("#autoscroll-button_top").data "state", "enabled"
      $("#autoscroll-button_top").text "disable autoscroll"


@getBuild = (buildPath, buildId) ->
  console.log "run"
  setTimeout (->
    $.get buildPath + ".js?bid=" + buildId
  ), 3000

@checkAutoscroll = ->
  $("html,body").scrollTop $("#build-trace").height()  if "enabled" is $("#autoscroll-button_top").data("state")
