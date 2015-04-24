# SH5wysiwyg
#
class SH5wysiwyg

  _defaults =
    bootstrap: false
    commands: [
      'bold',
      'color',
      'background-color',
      'underline',
      'link',
      'border',
      'image',
      'movie'
    ]
    imageUploadTo: ''

  constructor: (@element, options) ->
    @settings  = $.extend {}, _defaults, options
    @toolbar   = new Toolbar(@settings.commands, @settings.bootstrap)
    @init()

  init: ->
    $(@element).hide()
    
    $(@element).before($(@toolbar.element))
    $(@element).before($("<article class='sh5wysiwyg-article' contentEditable='true'></article>"))

  execCommand: (command)->
    switch command
      
      when "bold"
        if document.getSelection().toString().length > 0
          document.execCommand("bold", false)
      
      when "color"
        if document.getSelection().toString().length > 0
          $node = $(document.getSelection().anchorNode.parentNode)
          color = prompt('Color:', $node.css('color'))
          if color == ""
            document.execCommand("removeFormat", false, "foreColor")
          else
            document.execCommand("foreColor", false, color)
      
      when "background-color"
        if document.getSelection().toString().length > 0
          $node = $(document.getSelection().anchorNode.parentNode)
          bgColor = prompt('Background Color:', $node.css('background-color'))
          if bgColor == ""
            $node.css('background-color', "")
          else
            document.execCommand('backColor', false, bgColor)
      
      when "underline"
        if document.getSelection().toString().length > 0
          document.execCommand("underline", false)
      
      when "link"
        if document.getSelection().toString().length > 0
          url = prompt('URL:')
          if url == ""
            document.execCommand('unlink',false)
          else
            document.execCommand('createLink',false,url)
            
      
      when "border"
        sel = document.getSelection()
        if sel.toString().length > 0
          $node = $(sel.anchorNode.parentNode)
          if $node.hasClass 'sh5wysiwyg-frame'
            $(sel.anchorNode.parentNode).css
              display: 'block'
              border: 'none'
              padding: 0
              margin: 0
          else
            $(sel.anchorNode.parentNode).css
              display: 'inline-block'
              border: '1px solid #777'
              padding: '4px'
              margin: '4px'
          $node.toggleClass 'sh5wysiwyg-frame'
      
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

      when "class"
        sel = document.getSelection()
        if sel.toString().length > 0
          cls = prompt('Class Name:', sel.anchorNode.parentNode.className)
          sel.anchorNode.parentNode.className = cls