# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
#= require jquery
#= require jquery_ujs
#= require_tree .
#
#

$ ->
  $('.sync-now').on 'click', ->
    alert(1)
    $(this).addClass('icon-spin')
  $('.edit-runner-link').on 'click', ->
    descr = $(this).closest('.runner-description').first()
    descr.hide()
    descr.next('.runner-description-form').show()

  $('.assign-all-runner').on 'click', ->
    $(this).replaceWith('<i class="icon-refresh icon-spin"></i> Assign in progress..')
