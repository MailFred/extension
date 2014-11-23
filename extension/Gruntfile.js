module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    chrome_manifest: grunt.file.readJSON('chrome/manifest.json'),
    uglify: {
      options: {
        sourceMap: true,
        sourceMapIncludeSources: true,
      },
      build: {
        files: [{
          expand: true,
          cwd: 'chrome/js/build',
          src: '*.coffee.js',
          dest: 'chrome/js/build',
          ext: '.min.js'
        }]
      }
    },

    coffee: {
      compile: {
        options: {
          sourceMap: true
        },
        expand: true,
        flatten: true,
        cwd: 'chrome/js/src',
        src: ['*.coffee'],
        dest: 'chrome/js/build',
        ext: '.coffee.js'
      }
    },

    less: {
      build: {
        files: {
          "chrome/css/styles.css": "chrome/css/styles.less"
        }
      }
    },

    watch: {
      scripts: {
        files: [
          'chrome/js/src/*.coffee'
        ],
        tasks: ['coffee:compile', 'uglify:build'],
        options: {
          interrupt: true,
        },
      },
      styles: {
        files: [
        'chrome/css/*.less'
        ],
        tasks: ['less:build'],
        options: {
          interrupt: true,
        },
      },
    },

    compress: {
      main: {
        options: {
          level: 9,
          pretty: true,
          archive: 'build/chrome.zip'
        },
        files: [
          {
            src:  [
                    'chrome/_locales/**',
                    'chrome/css/*.css',
                    'chrome/html/*.html',
                    'chrome/manifest.json',
                    'chrome/js/build/*.min.js',
                    'chrome/images/**'
            ],
            dest: '/',
            filter: 'isFile'
          },
          {
            src: [
              'chrome/bower_components/eventr/build/eventr.min.js',
              'chrome/bower_components/gmailr/build/gmailr.min.js',
              'chrome/bower_components/gmailui/build/gmailui.min.js',
              'chrome/bower_components/jquery/dist/jquery.min.js',
              'chrome/bower_components/jquery-deparam/jquery.ba-deparam.min.js',
              'chrome/bower_components/moment/min/moment.min.js',
              'chrome/bower_components/pikaday/pikaday.js',
              'chrome/bower_components/pikaday/css/pikaday.css',
              'chrome/bower_components/lodash/dist/lodash.min.js',
              'chrome/bower_components/yepnope/yepnope.1.5.4-min.js',
            ],
            dest: '/',
            filter: 'isFile'
          },
        ]
      }
    },

    crx: {
      dev: {
        "src": "./chrome",
        "dest": "build/<%= pkg.name %>-<%= chrome_manifest.version %>-dev.crx",
        "privateKey": "chrome.pem",
        "exclude": [
          "**/*.md",
          "js/src/*",
          "js/build/*.coffee.js",
          "**/*.map",
          "**/Gruntfile.js",
          "**/.*",
          "**/LICENSE",
          "**/*.less",
          "bower.json",
          "bower_components/**/*.json",
          "bower_components/**/*.txt",
          "bower_components/**/*.html",
          "bower_components/eventr/src",
          "bower_components/gmailr/src",
          "bower_components/gmailui/src",
          "bower_components/jquery/src",
          "bower_components/jquery-deparam/unit.js",
          "bower_components/lodash/dist/*.underscore.*",
          "bower_components/lodash/dist/*.compat.*",
          "bower_components/moment/benchmarks",
          "bower_components/moment/locale",
          "bower_components/moment/scripts",
          "bower_components/moment/*.*",
          "bower_components/moment/min/*locales*",
          "bower_components/pikaday/css/site.css",
          "bower_components/pikaday/plugins",
          "bower_components/yepnope/tests",
          "bower_components/yepnope/prefixes",
          "bower_components/yepnope/plugins",
          "bower_components/yepnope/compress",
          "bower_components/yepnope/yepnope.js"
        ]
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-compress');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-crx');

  grunt.registerTask('build', [
    'coffee:compile',
    'uglify:build',
    'less:build'
  ]);

  grunt.registerTask('release', [
    'build',
    'compress:main'
  ]);

  grunt.registerTask('travis', ['coffee:compile', 'less:build']);

};
