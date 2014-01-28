$ ->
  $("#autoscroll-button").bind "click", ->
    state = $(this).data("state")
    if "enabled" is state
      $(this).data "state", "disabled"
      $(this).text "enable autoscroll"
    else
      $(this).data "state", "enabled"
      $(this).text "disable autoscroll"

@getBuild = (buildPath, buildId) ->
  console.log "run"
  setTimeout (->
    $.get buildPath + ".js?bid=" + buildId
  ), 3000

@checkAutoscroll = ->
  $("html,body").scrollTop $("#build-trace").height()  if "enabled" is $("#autoscroll-button").data("state")
