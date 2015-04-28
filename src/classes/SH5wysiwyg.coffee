# SH5wysiwyg
#
class SH5wysiwyg

  _defaults =
    bootstrap: false
    commands: [
      'font-size',
      'bold',
      'color',
      'background-color',
      'underline',
      'link',
      'border',
      'image',
      'movie',
      'source'
    ]
    minFontSize: 12
    maxFontSize: 20
    imageUploadTo: ''

  constructor: (@source, options) ->
    @settings      = $.extend {}, _defaults, options
    @toolbar       = new Toolbar(@settings.commands, @settings.bootstrap)
    bootstrapClass = if @settings.bootstrap then " form-control" else ""
    @$article       = $("<article class='sh5wysiwyg-article#{bootstrapClass}' contentEditable='true'>#{$(@source).val()}</article>")
    @init()

  init: ->
    $(@source).hide()
    $(@source).before($(@toolbar.element))
    $(@source).before(@$article)

  setSourceVal: ->
    $(@source).val(@$article.html())

  setEditorVal: ->
    @$article.html($(@source).val())

  execCommand: (command)->

    selection  = document.getSelection()
    isSelected = selection.toString().length > 0
    if isSelected
      pNode      = selection.anchorNode.parentNode
      pNodeName  = pNode.nodeName.toLowerCase()

    switch command
      
      when "font-size"
        if isSelected
          fontSize = parseInt(prompt('Font Size (1-7):'))
          document.execCommand("fontSize", false, fontSize)
          node = document.getSelection().anchorNode.parentNode
          nodeName = node.nodeName.toLowerCase()
          interval = Math.round((@settings.maxFontSize - @settings.minFontSize) / 6 * 100) / 100
          newFontSize = @settings.minFontSize + interval * (fontSize - 1)
          $(node).removeAttr("size").css("font-size", "#{newFontSize}px") if nodeName == "font"

      when "bold"
        if isSelected
          document.execCommand("bold", false)
      
      when "color"
        if isSelected
          currentColor = if (pNodeName == "font") then $(pNode).css('color') else ""
          color = prompt('Color:', currentColor)
          if color == ""
            $(pNode).css("color", "") if pNodeName == "font"
          else
            document.execCommand("foreColor", false, color)
            node = document.getSelection().anchorNode.parentNode
            nodeName = node.nodeName.toLowerCase()
            $(node).removeAttr("color").css("color", color) if nodeName == "font"
      
      when "background-color"
        if isSelected
          bgColor = prompt('Background Color:', $(pNode).css('background-color'))
          if bgColor == ""
            $(pNode).css('background-color', "")
          else
            document.execCommand('backColor', false, bgColor)
      
      when "underline"
        if isSelected
          document.execCommand("underline", false)
      
      when "link"
        if isSelected
          url = prompt('URL:')
          if url == ""
            document.execCommand('unlink',false)
          else
            document.execCommand('createLink',false,url)
      
      when "border"
        if isSelected
          if $(pNode).hasClass 'sh5wysiwyg-frame'
            $(pNode).css
              display: 'block'
              border: 'none'
              padding: 0
              margin: 0
          else
            $(pNode).css
              display: 'inline-block'
              border: '1px solid #777'
              padding: '4px'
              margin: '4px'
          $(pNode).toggleClass 'sh5wysiwyg-frame'
      
      when "image"
        $('.sh5wysiwyg-file:first').trigger('click')
      
      when "movie"
        url = prompt('URL:', '')
        if url
          if url.match(/^http:\/\/(?:www\.nicovideo\.jp\/watch|nico\.ms)\/[a-z][a-z](\d+)/)
            id = RegExp.$1
            host = parseInt(id)%4 + 1
            thumbUrl = "http://tn-skr#{host}.smilevideo.jp/smile?i=#{id}"
            insertFormat =  "<img class='sh5wysiwyg-niconico' src='#{thumbUrl}' data-url='#{url}'>"
            # insertFormat += '<script type="text/javascript" src="http://ext.nicovideo.jp/thumb_watch/sm23937144"></script><noscript><a href="http://www.nicovideo.jp/watch/sm23937144?ref=top_push_flog"></a></noscript>'
            document.execCommand('insertHTML', false, insertFormat)

      when "source"
        @setSourceVal()
        @$article.hide()
        $(@source).show()
        $('.sh5wysiwyg-toolbar > input[value="source"]').hide()
        $('.sh5wysiwyg-toolbar > input[value="editor"]').show()
      
      when "editor"
        @setEditorVal()
        $(@source).hide()
        @$article.show()
        $('.sh5wysiwyg-toolbar > input[value="editor"]').hide()
        $('.sh5wysiwyg-toolbar > input[value="source"]').show()