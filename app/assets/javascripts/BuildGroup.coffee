class BuildGroup
  @interval: null

  constructor: (build_group_url, build_group_status) ->
    clearInterval(BuildGroup.interval)

    if build_group_status == "running" || build_group_status == "pending"
      BuildGroup.interval = setInterval =>
        if window.location.href is build_group_url
          Turbolinks.visit build_group_url
      , 5000

@BuildGroup = BuildGroup
