/*
 *  jquery.simple-html5-wysiwyg - v0.0.2
 *  Simple jQuery WYSIWYG Plugin
 *  https://github.com/Iwark/jquery.simple-html5-wysiwyg
 *
 *  Made by Iwark <iwark02@gmail.com>
 *  Under MIT License
 */
(function() {
  var SH5wysiwyg, Toolbar;

  SH5wysiwyg = (function() {
    var _defaults;

    _defaults = {
      bootstrap: false,
      commands: ['bold', 'color', 'background-color', 'underline', 'link', 'border', 'image', 'movie'],
      imageUploadTo: ''
    };

    function SH5wysiwyg(element, options) {
      this.element = element;
      this.settings = $.extend({}, _defaults, options);
      this.toolbar = new Toolbar(this.settings.commands, this.settings.bootstrap);
      this.init();
    }

    SH5wysiwyg.prototype.init = function() {
      $(this.element).hide();
      $(this.element).before($(this.toolbar.element));
      return $(this.element).before($("<article class='sh5wysiwyg-article' contentEditable='true'></article>"));
    };

    SH5wysiwyg.prototype.execCommand = function(command) {
      var $node, bgColor, cls, color, host, id, insertFormat, sel, thumbUrl, url;
      switch (command) {
        case "bold":
          if (document.getSelection().toString().length > 0) {
            return document.execCommand("bold", false);
          }
          break;
        case "color":
          if (document.getSelection().toString().length > 0) {
            $node = $(document.getSelection().anchorNode.parentNode);
            color = prompt('Color:', $node.css('color'));
            if (color === "") {
              return document.execCommand("removeFormat", false, "foreColor");
            } else {
              return document.execCommand("foreColor", false, color);
            }
          }
          break;
        case "background-color":
          if (document.getSelection().toString().length > 0) {
            $node = $(document.getSelection().anchorNode.parentNode);
            bgColor = prompt('Background Color:', $node.css('background-color'));
            if (bgColor === "") {
              return $node.css('background-color', "");
            } else {
              return document.execCommand('backColor', false, bgColor);
            }
          }
          break;
        case "underline":
          if (document.getSelection().toString().length > 0) {
            return document.execCommand("underline", false);
          }
          break;
        case "link":
          if (document.getSelection().toString().length > 0) {
            url = prompt('URL:');
            if (url === "") {
              return document.execCommand('unlink', false);
            } else {
              return document.execCommand('createLink', false, url);
            }
          }
          break;
        case "border":
          sel = document.getSelection();
          if (sel.toString().length > 0) {
            $node = $(sel.anchorNode.parentNode);
            if ($node.hasClass('sh5wysiwyg-frame')) {
              $(sel.anchorNode.parentNode).css({
                display: 'block',
                border: 'none',
                padding: 0,
                margin: 0
              });
            } else {
              $(sel.anchorNode.parentNode).css({
                display: 'inline-block',
                border: '1px solid #777',
                padding: '4px',
                margin: '4px'
              });
            }
            return $node.toggleClass('sh5wysiwyg-frame');
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
          sel = document.getSelection();
          if (sel.toString().length > 0) {
            cls = prompt('Class Name:', sel.anchorNode.parentNode.className);
            return sel.anchorNode.parentNode.className = cls;
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
        if (!$.data(this, pluginName)) {
          $(this).addClass(pluginName);
          return $.data(this, pluginName, new SH5wysiwyg(this, options));
        }
      });
      $('.sh5wysiwyg-article').on('focus', function() {
        var $div, range, sel;
        sel = document.getSelection();
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
      $('.sh5wysiwyg-toolbar > input').on('click', function() {
        var target, wysiwyg;
        target = $(this).parent().nextAll("." + pluginName + ":first");
        wysiwyg = $.data(target[0], pluginName);
        return wysiwyg.execCommand($(this).val());
      });
      return $('.sh5wysiwyg-file').on('change', function(e) {
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
          success: function(data) {
            var json;
            json = JSON.parse(data);
            return document.execCommand('insertImage', false, json.url);
          },
          error: function(e) {
            return alert("Error: " + e);
          }
        });
      });
    };
  })(jQuery);

}).call(this);
