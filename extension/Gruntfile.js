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

    bump: {
      options: {
        files: [
          'package.json',
          'chrome/bower.json',
          'chrome/manifest.json'
        ],
        updateConfigs: ['pkg', 'chrome_manifest'],
        commit: true,
        commitMessage: 'Release v%VERSION%',
        commitFiles: [
          'package.json',
          'chrome/bower.json',
          'chrome/manifest.json'
        ],
        createTag: true,
        tagName: 'v%VERSION%',
        tagMessage: 'Version %VERSION%',
        push: true,
        pushTo: 'origin',
        gitDescribeOptions: '--tags --always --abbrev=1 --dirty=-d',
        globalReplace: false
      }
    },

    crx: {
      both: {
        "src": "./chrome",
        "dest": "./build",
        "zipDest": "./build",
        "privateKey": "key.pem",
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
    },

    notify: {
      watch: {
        options: {
          title: 'Watch run',
          message: 'Recompiling completed',
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-compress');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-crx');
  grunt.loadNpmTasks('grunt-bump');
  grunt.loadNpmTasks('grunt-notify');

  grunt.registerTask('build', [
    'coffee:compile',
    'uglify:build',
    'less:build'
  ]);

  grunt.registerTask('release', 'Bump, build and release.', function(type) {
    grunt.task.run([
      'bump-only:' + (type || 'patch'),
      'build',
      'crx:both',
      'bump-commit'
    ]);
  });

  grunt.registerTask('travis', ['coffee:compile', 'less:build']);

};
