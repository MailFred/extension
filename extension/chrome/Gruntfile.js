module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    manifest: grunt.file.readJSON('manifest.json'),
    uglify: {
      options: {
        sourceMap: true,
        sourceMapIncludeSources: true,
      },
      build: {
        files: [{
          expand: true,
          cwd: 'js/build',
          src: '*.coffee.js',
          dest: 'js/build',
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
        cwd: 'js/src',
        src: ['*.coffee'],
        dest: 'js/build',
        ext: '.coffee.js'
      }
    },

    less: {
      build: {
        files: {
          "css/styles.css": "css/styles.less"
        }
      }
    },

    watch: {
      scripts: {
        files: [
          'js/src/*.coffee'
        ],
        tasks: ['coffee:compile', 'uglify:build'],
        options: {
          interrupt: true,
        },
      },
      styles: {
        files: [
        'css/*.less'
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
          archive: '../chrome.zip'
        },
        files: [
          {
            src:  [
                    '_locales/**',
                    'css/*.css',
                    'html/*.html',
                    'manifest.json',
                    'js/build/*.min.js',
                    'images/**'
            ],
            dest: '/',
            filter: 'isFile'
          },
          {
            src: [
              'bower_components/eventr/build/eventr.min.js',
              'bower_components/gmailr/build/gmailr.min.js',
              'bower_components/gmailui/build/gmailui.min.js',
              'bower_components/jquery/dist/jquery.min.js',
              'bower_components/jquery-deparam/jquery.ba-deparam.min.js',
              'bower_components/moment/min/moment.min.js',
              'bower_components/pikaday/pikaday.js',
              'bower_components/pikaday/css/pikaday.css',
              'bower_components/lodash/dist/lodash.min.js',
              'bower_components/yepnope/yepnope.1.5.4-min.js',
            ],
            dest: '/',
            filter: 'isFile'
          },
        ]
      }
    },

    crx: {
      dev: {
        "src": ".",
        "dest": "../<%= pkg.name %>-<%= manifest.version %>-dev.crx",
        "privateKey": "../chrome.pem",
        "exclude": [
          "js/src/*",
          "js/build/*.coffee.js",
          "**/*.map",
          "node_modules/**"
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
