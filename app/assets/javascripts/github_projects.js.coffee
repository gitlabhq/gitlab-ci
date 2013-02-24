class GithubProjects
  constructor: ->
    @el     = $(".github_projects")
    @loader = $('.github_projects_loader')
    @url    = @el.attr("rel") + "?_=" + new Date().getTime()

    @el.on "change", ".github_repo_instance input", @create

  reload: =>
    @loader.show()
    @el.html("")
    $.getScript @url

  html: (data) =>
    @loader.hide()
    @el.html(data)

  create: (ev) =>
    target = $(ev.currentTarget)
    cont   = target.parents(".github_repo_instance")
    params = {github_repo: target.data("githubRepo") }
    target.attr("disabled", "disabled")
    $.ajax
      url: @url
      type: "POST"
      data: params
      dataType: 'text'
      success: (ev) =>
        cont.fadeOut()

$(document).ready ->
  $(".github_projects").each ->
    window.githubProjects = new GithubProjects
    window.githubProjects.reload()

  $("form.edit_project .regenerate-keys-btn").each (el) ->
    $(this)
    .on "ajax:before", ->
      $(this).attr("disabled", "disabled")
    .on "ajax:success", ->
      $(this).removeAttr("disabled")


