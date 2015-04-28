do ($ = jQuery) ->

  pluginName  = "sh5wysiwyg"

  $.fn[pluginName] = (options) ->
    @each ->
      unless $(this).data pluginName
        $(this).addClass(pluginName)
        $(this).data pluginName, new SH5wysiwyg this, options

    # Add wrapper div to the empty article(textarea) when focused.
    $('.sh5wysiwyg-article').off('focus.sh5').on 'focus.sh5', ->
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

    # Execute commands
    $('.sh5wysiwyg-toolbar > input').off('click.sh5').on 'click.sh5', ->
      $target = $(this).parent().nextAll(".#{pluginName}:first")
      wysiwyg = $target.data pluginName
      wysiwyg.execCommand $(this).val()

    # Upload Image via AJAX and insert to the article(textarea).
    $('.sh5wysiwyg-file').off('change.sh5').on 'change.sh5', (e)->
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

    # Set articles value to textareas.
    $(".#{pluginName}").parents('form').off('submit.sh5').on 'submit.sh5', ->
      $(".#{pluginName}").each ->
        $(this).data(pluginName).setSourceVal().convertThumbToMovie()