# Toolbar
#
class Toolbar

  # Construct a new toolbar.
  #
  # @param [Array] commands the commands list
  #
  constructor: (@commands, @bootstrap)->
    @element = "<div class='sh5wysiwyg-toolbar'>"
    @bootstrapBtn = if @bootstrap then " class='btn btn-default'" else ""
    @init()

  init: ->
    for command in @commands
      @element += "<input type='button' value='#{command}'#{@bootstrapBtn}>"
    if $.inArray('image', @commands)
      @element += "<input type='file' class='sh5wysiwyg-file' style='position: absolute; top: -50px; left: 0; width: 0; height: 0; opacity: 0; filter: alpha(opacity=0);'>"
    @element += "</div>"