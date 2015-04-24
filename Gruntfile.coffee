module.exports = (grunt)->

  grunt.initConfig

    # Import package manifest
    pkg: grunt.file.readJSON("package.json")

    # Bower Installation
    bower:
      install:
        options:
          install: true
          cleanTargetDir: true
          cleanBowerDir: false

    # CoffeeScript compilation
    coffee:
      compile:
        options:
          join: true
        files:
          'src/jquery.simple-html5-wysiwyg.js': ['src/**/*.coffee']

    # Banner definitions
    meta:
      banner:
        """
        /*
         *  <%= pkg.title || pkg.name %> - v<%= pkg.version %>
         *  <%= pkg.description %>
         *  <%= pkg.homepage %>
         *
         *  Made by <%= pkg.author %>
         *  Under <%= pkg.license %> License
         */

        """

    # Concat definitions
    concat:
      options:
        banner: "<%= meta.banner %>"
      dist:
        src: ['src/jquery.simple-html5-wysiwyg.js'],
        dest: 'dist/jquery.simple-html5-wysiwyg.js'

    # Minify definitions
    uglify:
      target:
        files: [
          'dist/jquery.simple-html5-wysiwyg.min.js': ['dist/jquery.simple-html5-wysiwyg.js']
        ]
      options:
        banner: "<%= meta.banner %>"

    # Generate Codo documentation for CoffeeScript
    codo:
      src: [
        'src'
      ]

    # Watch for changes to source
    watch:
      coffee:
        files: ['src/**/*.coffee'],
        tasks: ['coffee', 'concat', 'uglify', 'codo']

    grunt.loadNpmTasks('grunt-bower-task')
    grunt.loadNpmTasks('grunt-contrib-coffee')
    grunt.loadNpmTasks("grunt-contrib-concat")
    grunt.loadNpmTasks('grunt-contrib-uglify')
    grunt.loadNpmTasks('grunt-codo')
    grunt.loadNpmTasks('grunt-contrib-watch')

    grunt.registerTask('default', ['bower:install','watch'])