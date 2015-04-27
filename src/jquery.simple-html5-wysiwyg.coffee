do ($ = jQuery) ->

  pluginName = "sh5wysiwyg"

  $.fn[pluginName] = (options) ->
    @each ->
      unless $.data @, pluginName
        $(@).addClass(pluginName)
        $.data @, pluginName, new SH5wysiwyg @, options

    $('.sh5wysiwyg-article').on 'focus', ->
      sel = document.getSelection()
      unless $(this).html()
        $div = $("<div></div>")
        $(this).html($div)
        range = document.createRange()
        range.selectNode($div[0])
        sel.addRange(range)
        $(this).html('')
        document.execCommand('insertParagraph',false,null)
        if $(this).find('div').length > 1
          $(this).find('div:first').remove()

    $('.sh5wysiwyg-toolbar > input').on 'click', ->
      target = $(this).parent().nextAll(".#{pluginName}:first")
      wysiwyg = $.data target[0], pluginName
      wysiwyg.execCommand $(this).val()

    $('.sh5wysiwyg-file').on 'change', (e)->
      return if document.getSelection().toString().length > 0
      e.preventDefault()
      fd = new FormData();
      fd.append("file", this.files[0])
      $.ajax
        url: options.imageUploadTo
        type: "POST"
        data: fd
        processData: false
        contentType: false
        dataType: "json"
        success: (json)->
          document.execCommand('insertImage',false,json.url)
        error: (jqXHR, textStatus, errorThrown)->
          alert "Error textStatus:#{textStatus}, errorThrown:#{errorThrown}"