class Build
  @interval: null

  constructor: (build_url, build_status) ->
    clearInterval(Build.interval)

    if build_status == "running" || build_status == "pending"
      # Automatically enable autoscroll
      $("#autoscroll-button").data "state", "enabled"
      $("#autoscroll-button").text "disable autoscroll"

      #
      # Bind autoscroll button to follow build output
      #
      $("#autoscroll-button").bind "click", ->
        state = $(this).data("state")
        if "enabled" is state
          $(this).data "state", "disabled"
          $(this).text "enable autoscroll"
        else
          $(this).data "state", "enabled"
          $(this).text "disable autoscroll"

      #
      # Position autoscroll button with window scroll
      #
      $(window).on 'scroll':->
        basePadding = 5
        padding = 10
        currentScroll = $(window).scrollTop()
        top = $(".bash").offset().top
        if currentScroll > top - padding
          $("#autoscroll-container").stop().animate({top: currentScroll - top + padding + basePadding}, 200)
        else
          $("#autoscroll-container").stop().animate({top: basePadding}, 200)

      #
      # Check for new build output if user still watching build page
      # Only valid for runnig build when output changes during time
      #
      Build.interval = setInterval =>
        if window.location.href is build_url
          $.ajax
            url: build_url
            dataType: "json"
            success: (build) =>
              if build.status == "running" && build.status == build_status
                $('#build-trace code').html build.trace_html
                $('#build-trace code').append '<br/><i class="icon-refresh icon-spin"/>'
                @checkAutoscroll()
              else
                Turbolinks.visit build_url
      , 4000

  checkAutoscroll: ->
    $("html,body").scrollTop $("#build-trace").height()  if "enabled" is $("#autoscroll-button").data("state")

@Build = Build
