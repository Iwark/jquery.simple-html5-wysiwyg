(function() {
  var SH5wysiwyg, Toolbar;

  SH5wysiwyg = (function() {
    var _defaults;

    _defaults = {
      bootstrap: false,
      commands: ['font-size', 'bold', 'color', 'background-color', 'underline', 'link', 'border', 'image', 'movie'],
      minFontSize: 12,
      maxFontSize: 20,
      imageUploadTo: ''
    };

    function SH5wysiwyg(element, options) {
      this.element = element;
      this.settings = $.extend({}, _defaults, options);
      this.toolbar = new Toolbar(this.settings.commands, this.settings.bootstrap);
      this.bootstrapClass = this.settings.bootstrap ? " form-control" : "";
      this.init();
    }

    SH5wysiwyg.prototype.init = function() {
      $(this.element).hide();
      $(this.element).before($(this.toolbar.element));
      return $(this.element).before($("<article class='sh5wysiwyg-article" + this.bootstrapClass + "' contentEditable='true'>" + ($(this.element).val()) + "</article>"));
    };

    SH5wysiwyg.prototype.execCommand = function(command) {
      var bgColor, color, currentColor, fontSize, host, id, insertFormat, interval, isSelected, newFontSize, node, nodeName, pNode, pNodeName, selection, thumbUrl, url;
      selection = document.getSelection();
      isSelected = selection.toString().length > 0;
      if (isSelected) {
        pNode = selection.anchorNode.parentNode;
        pNodeName = pNode.nodeName.toLowerCase();
      }
      switch (command) {
        case "font-size":
          if (isSelected) {
            fontSize = parseInt(prompt('Font Size (1-7):'));
            document.execCommand("fontSize", false, fontSize);
            node = document.getSelection().anchorNode.parentNode;
            nodeName = node.nodeName.toLowerCase();
            interval = Math.round((this.settings.maxFontSize - this.settings.minFontSize) / 6 * 100) / 100;
            newFontSize = this.settings.minFontSize + interval * (fontSize - 1);
            if (nodeName === "font") {
              return $(node).removeAttr("size").css("font-size", newFontSize + "px");
            }
          }
          break;
        case "bold":
          if (isSelected) {
            return document.execCommand("bold", false);
          }
          break;
        case "color":
          if (isSelected) {
            currentColor = pNodeName === "font" ? $(pNode).css('color') : "";
            color = prompt('Color:', currentColor);
            if (color === "") {
              if (pNodeName === "font") {
                return $(pNode).css("color", "");
              }
            } else {
              document.execCommand("foreColor", false, color);
              node = document.getSelection().anchorNode.parentNode;
              nodeName = node.nodeName.toLowerCase();
              if (nodeName === "font") {
                return $(node).removeAttr("color").css("color", color);
              }
            }
          }
          break;
        case "background-color":
          if (isSelected) {
            bgColor = prompt('Background Color:', $(pNode).css('background-color'));
            if (bgColor === "") {
              return $(pNode).css('background-color', "");
            } else {
              return document.execCommand('backColor', false, bgColor);
            }
          }
          break;
        case "underline":
          if (isSelected) {
            return document.execCommand("underline", false);
          }
          break;
        case "link":
          if (isSelected) {
            url = prompt('URL:');
            if (url === "") {
              return document.execCommand('unlink', false);
            } else {
              return document.execCommand('createLink', false, url);
            }
          }
          break;
        case "border":
          if (isSelected) {
            if ($(pNode).hasClass('sh5wysiwyg-frame')) {
              $(pNode).css({
                display: 'block',
                border: 'none',
                padding: 0,
                margin: 0
              });
            } else {
              $(pNode).css({
                display: 'inline-block',
                border: '1px solid #777',
                padding: '4px',
                margin: '4px'
              });
            }
            return $(pNode).toggleClass('sh5wysiwyg-frame');
          }
          break;
        case "image":
          return $('.sh5wysiwyg-file:first').trigger('click');
        case "movie":
          url = prompt('URL:', '');
          if (url) {
            if (url.match(/^http:\/\/(?:www\.nicovideo\.jp\/watch|nico\.ms)\/[a-z][a-z](\d+)/)) {
              id = RegExp.$1;
              host = parseInt(id) % 4 + 1;
              thumbUrl = "http://tn-skr" + host + ".smilevideo.jp/smile?i=" + id;
              insertFormat = "<img class='sh5wysiwyg-niconico' src='" + thumbUrl + "' data-url='" + url + "'>";
              return document.execCommand('insertHTML', false, insertFormat);
            }
          }
          break;
        case "class":
          if (isSelected) {
            return pNode.className = prompt('Class Name:', pNode.className);
          }
      }
    };

    return SH5wysiwyg;

  })();

  Toolbar = (function() {
    function Toolbar(commands, bootstrap) {
      this.commands = commands;
      this.bootstrap = bootstrap;
      this.element = "<div class='sh5wysiwyg-toolbar'>";
      this.bootstrapBtn = this.bootstrap ? " class='btn btn-default'" : "";
      this.init();
    }

    Toolbar.prototype.init = function() {
      var command, i, len, ref;
      ref = this.commands;
      for (i = 0, len = ref.length; i < len; i++) {
        command = ref[i];
        this.element += "<input type='button' value='" + command + "'" + this.bootstrapBtn + ">";
      }
      if ($.inArray('image', this.commands)) {
        this.element += "<input type='file' class='sh5wysiwyg-file' style='position: absolute; top: -50px; left: 0; width: 0; height: 0; opacity: 0; filter: alpha(opacity=0);'>";
      }
      return this.element += "</div>";
    };

    return Toolbar;

  })();

  (function($) {
    var pluginName;
    pluginName = "sh5wysiwyg";
    return $.fn[pluginName] = function(options) {
      this.each(function() {
        if (!$(this).data(pluginName)) {
          $(this).addClass(pluginName);
          return $(this).data(pluginName, new SH5wysiwyg(this, options));
        }
      });
      $('.sh5wysiwyg-article').off('focus').on('focus', function() {
        var $div, range, sel;
        sel = document.getSelection();
        if (sel.anchorNode !== this) {
          return;
        }
        if (!$(this).html()) {
          $div = $("<div></div>");
          $(this).html($div);
          range = document.createRange();
          range.selectNode($div[0]);
          sel.addRange(range);
          $(this).html('');
          document.execCommand('insertParagraph', false, null);
          if ($(this).find('div').length > 1) {
            return $(this).find('div:first').remove();
          }
        }
      });
      $('.sh5wysiwyg-toolbar > input').off('click').on('click', function() {
        var $target, wysiwyg;
        $target = $(this).parent().nextAll("." + pluginName + ":first");
        wysiwyg = $target.data(pluginName);
        return wysiwyg.execCommand($(this).val());
      });
      return $('.sh5wysiwyg-file').off('change').on('change', function(e) {
        var fd;
        if (document.getSelection().toString().length > 0) {
          return;
        }
        e.preventDefault();
        fd = new FormData();
        fd.append("file", this.files[0]);
        return $.ajax({
          url: options.imageUploadTo,
          type: "POST",
          data: fd,
          processData: false,
          contentType: false,
          dataType: "json",
          success: function(json) {
            return document.execCommand('insertImage', false, json.url);
          },
          error: function(jqXHR, textStatus, errorThrown) {
            return alert("Error textStatus:" + textStatus + ", errorThrown:" + errorThrown);
          }
        });
      });
    };
  })(jQuery);

}).call(this);
