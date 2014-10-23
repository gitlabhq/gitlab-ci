class RefreshPage
  @interval: null

  constructor: (page_url, refresh_page = true, refresh_interval = 5000) ->
    clearInterval(RefreshPage.interval)

    if refresh_page
      RefreshPage.interval = setInterval =>
        if window.location.href is page_url
          Turbolinks.visit page_url
        else
          clearInterval(RefreshPage.interval)
      , refresh_interval

@RefreshPage = RefreshPage

