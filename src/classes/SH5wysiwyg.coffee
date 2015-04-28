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
    if @$article.html().length > 0
      @convertMovieToThumb()

  setSourceVal: ->
    $(@source).val @$article.html()
    return this

  setEditorVal: ->
    @$article.html $(@source).val()
    return this

  convertThumbToMovie: ->
    $source = $("<div>" + $(@source).val() + "</div>")
    self = this
    
    # Niconico Movie
    $source.find('img.sh5wysiwyg-niconico-thumb').each ->
      url = $(this).data('url')
      movie = self.getNiconicoMovie(url)
      $(this).replaceWith(movie)

    # Youtube
    $source.find('img.sh5wysiwyg-youtube-thumb').each ->
      youtubeId = $(this).data('youtube-id')
      movie = self.getYoutubeMovie(youtubeId)
      $(this).replaceWith(movie)

    $(@source).val $source.html()

  convertMovieToThumb: ->
    $html = $("<div>" + @$article.html() + "</div>")
    self = this

    # Niconico Movie
    $html.find('div[name="wysiwyg-insert-niconico-movie"]').each ->
      url = $(this).find('noscript').html().match(/href="(.*?)"/)[1]
      thumb = self.getNiconicoThumbImg(url)
      $(this).replaceWith(thumb)

    # Youtube
    $html.find('object.wysiwyg-youtube').each ->
      url = $(this).attr('data')
      thumb = self.getYoutubeThumbImg(url)
      $(this).replaceWith(thumb)

    @$article.html $html.html()

  getNiconicoThumbImg: (url)->
    return "" unless url.match(/^http:\/\/(?:www\.nicovideo\.jp\/watch|nico\.ms)\/[a-z][a-z](\d+)/)
    id = RegExp.$1
    host = parseInt(id)%4 + 1
    thumbUrl = "http://tn-skr#{host}.smilevideo.jp/smile?i=#{id}"
    thumbImg = "<img class='sh5wysiwyg-niconico-thumb' style='width:425px; height:355px;' " +
      "src='#{thumbUrl}' data-url='#{url}'>"

  getNiconicoMovie: (url)->
    replacedUrl = url.replace("watch", "thumb_watch").replace("www", "ext")
    niconico =
      """
      <div name="wysiwyg-insert-niconico-movie">  
        <script type="text/javascript" src="#{replacedUrl}"></script>
        <noscript><a href="#{url}"></a></noscript>
      </div>
      """

  getYoutubeThumbImg: (url)->
    if url.match(/youtube\.com\/.*?v(?:=|\/)(.*?)(\&|$)/) || url.match(/youtu\.be\/(.*?)(\&|$)/)
      youtubeId = RegExp.$1
    else
      return ""
    "<img class='sh5wysiwyg-youtube-thumb' style='width:425px; height:355px;' " +
      "src='http://img.youtube.com/vi/#{youtubeId}/1.jpg' data-youtube-id='#{youtubeId}'>"

  getYoutubeMovie: (youtubeId)->
    youtube = 
      """
      <object class="wysiwyg-youtube" width="425" height="355" type="application/x-shockwave-flash" data="http://www.youtube.com/v/#{youtubeId}">
        <param name="movie" value="http://www.youtube.com/v/#{youtubeId}" />
        <param value="http://www.youtube.com/v/#{youtubeId}" name="movie" />
        <param value="transparent" name="wmode" />
        <param value="http://img.youtube.com/vi/#{youtubeId}/1.jpg" name="wysiwyg-insert-youtube-flash"></param>
      </object>
      """

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
        if url = prompt('URL:', '')

          # Youtube
          if url.match(/youtube\.com/) || url.match(/youtu\.be/)
            document.execCommand('insertHTML', false, @getYoutubeThumbImg(url))

          # Niconico Movie
          if url.match(/^http:\/\/(?:www\.nicovideo\.jp\/watch|nico\.ms)\/[a-z][a-z](\d+)/)            
            document.execCommand('insertHTML', false, @getNiconicoThumbImg(url))

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