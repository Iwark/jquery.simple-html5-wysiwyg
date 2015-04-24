jQuery Simple Html5 WYSIWYG ![Bower Version](https://badge.fury.io/bo/jquery.simple-html5-wysiwyg.svg)
----

### Simple jQuery WYSIWYG Plugin

## Usage

1. Include jQuery (and Bootstrap if you use).

  ```html
  <script src="../lib/jquery/jquery.js"></script>
  <link rel="stylesheet" href="../lib/bootstrap/bootstrap.css">
  ```

2. Include plugin's code:

  ```html
  <script src="dist/jquery.simple-html5-wysiwyg.min.js"></script>
  ```

3. Call the plugin:

  ```javascript
    $("#wysiwyg-area").sh5wysiwyg({
      bootstrap: true
    });
  ```

## Structure

The basic structure of the project is given in the following way:

```
├── bower_components/
│   └── ...
├── dist/
│   ├── jquery.simple-html5-wysiwyg.js
│   └── jquery.simple-html5-wysiwyg.min.js
├── doc/
│   └── ...
├── example/
│   └── index.html
├── lib/
│   └── ...
├── node_modules/
|   └── ...
├── src/
│   ├── classes/
│       |── SH5wysiwyg.coffee
│       └── Toolbar.coffee
│   ├── jquery.simple-html5-wysiwyg.coffee
│   └── jquery.simple-html5-wysiwyg.js
├── .gitignore
├── bower.json
├── Gruntfile.coffee
├── package.json
└── README.md
```

## History

Check [Releases](https://github.com/Iwark/jquery.simple-html5-wysiwyg/releases) for detailed changelog.

## License

[MIT License](http://iwark.mit-license.org) © Iwark