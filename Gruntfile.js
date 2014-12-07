module.exports = function(grunt) {

  var releasePath = "./build/<%= pkg.name %>-<%= manifest.version %>.zip";
  var sharedStaticSrc = [
    'shared/**',
    '!shared/{css,js}/**'
  ];

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    manifest: grunt.file.readJSON('chrome/manifest.json'),
    firefoxPackage: grunt.file.readJSON('firefox/package.json'),
    uglify: {
      options: {
        sourceMap: true,
        sourceMapIncludeSources: true,
      },
      chrome: {
        files: [{
          expand: true,
          cwd: 'chrome/lib/js/build',
          src: '*.coffee.js',
          dest: 'chrome/lib/js/build',
          ext: '.min.js'
        }]
      },
      firefox: {
        files: [{
          expand: true,
          cwd: 'firefox/lib/js/build',
          src: '*.coffee.js',
          dest: 'firefox/lib/js/build',
          ext: '.min.js'
        }]
      },
      shared: {
        files: [{
          expand: true,
          cwd: 'shared/js/build',
          src: '*.coffee.js',
          dest: 'shared/js/build',
          ext: '.min.js'
        }]
      }
    },

    coffee: {
      options: {
        sourceMap: true
      },
      chrome: {
        expand: true,
        flatten: true,
        cwd: 'chrome/lib/js/src',
        src: ['*.coffee'],
        dest: 'chrome/lib/js/build',
        ext: '.coffee.js'
      },
      firefox: {
        expand: true,
        flatten: true,
        cwd: 'firefox/lib/js/src',
        src: ['*.coffee'],
        dest: 'chrome/lib/js/build',
        ext: '.coffee.js'
      },
      shared: {
        expand: true,
        flatten: true,
        cwd: 'shared/js/src',
        src: ['*.coffee'],
        dest: 'shared/js/build',
        ext: '.coffee.js'
      }
    },

    less: {
      shared: {
        files: {
          "shared/css/build/styles.css": "shared/css/src/styles.less"
        }
      }
    },

    watch: {
      options: {
        interrupt: true,
      },
      'chrome.scripts': {
        files: [
          'chrome/js/src/*.coffee'
        ],
        tasks: ['coffee:chrome', 'uglify:chrome']
      },
      'firefox.scripts': {
        files: [
          'firefox/js/src/*.coffee'
        ],
        tasks: ['coffee:firefox', 'uglify:firefox']
      },
      'shared.scripts': {
        files: [
          'shared/js/src/*.coffee'
        ],
        tasks: ['coffee:shared', 'uglify:shared', 'copy:shared.scripts']
      },
      'shared.styles': {
        files: [
        'shared/css/*.less'
        ],
        tasks: ['less:shared', 'copy:shared.styles']
      },
      'shared.static': {
        files: sharedStaticSrc,
        tasks: ['copy:shared.static']
      }
    },

    bump: {
      options: {
        files: [
          'package.json',
          'bower.json',
          'chrome/manifest.json',
          'firefox/package.json'
        ],
        updateConfigs: ['pkg', 'manifest', 'firefoxPackage'],
        commit: true,
        commitMessage: 'Release v%VERSION%',
        commitFiles: [
          'package.json',
          'bower.json',
          'chrome/manifest.json',
          'firefox/package.json'
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
        "zipDest": releasePath,
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

    webstore_upload: {
      "accounts": {
        "support@mailfred.de": {
          publish: true,
          client_id: process.env.CLIENT_ID,
          client_secret: process.env.CLIENT_SECRET
        }
      },
      "extensions": {
        "beta": {
            account: 'support@mailfred.de',
            appID: "hcedpboddcjnggmdpbgdnlllkhmjjeil",
            zip: releasePath
        },
        "release": {
            account: 'support@mailfred.de',
            appID: "lijahkfnlmaikbppnbjeelhihaklhoim",
            zip: releasePath
        }
      }
    },

    "mozilla-addon-sdk": {
      'latest': {
        options: {
          revision: "1.17"
        }
      }
    },
    "mozilla-cfx-xpi": {
      'release': {
        options: {
          "mozilla-addon-sdk": "latest",
          extension_dir: "./firefox",
          dist_dir: "./build",
          arguments: "--strip-sdk"
        }
      }
    },
    "mozilla-cfx": {
      'release': {
        options: {
          "mozilla-addon-sdk": "latest",
          extension_dir: "./firefox",
          command: "run"
        }
      }
    },

    copy: {
      options: {
        timestamp: true
      },
      'shared.styles': {
        files: [
          {expand: true, src: ['shared/css/build/*.css'], dest: 'chrome/data/shared/css'},
          {expand: true, src: ['shared/css/build/*.css'], dest: 'firefox/data/shared/css'},
        ]
      },
      'shared.scripts': {
        files: [
          {expand: true, src: ['shared/js/build/**'], dest: 'chrome/data/shared/js'},
          {expand: true, src: ['shared/js/build/**'], dest: 'firefox/data/shared/js'},
        ]
      },
      'shared.static': {
        files: [
          {
            expand: true,
            src: sharedStaticSrc,
            dest: 'chrome/data'
          },
          {
            expand: true,
            src: sharedStaticSrc,
            dest: 'firefox/data'
          }
        ]
      }
    }
  });

  require('load-grunt-tasks')(grunt);

  grunt.registerTask('build', [
    'coffee',
    'uglify',
    'less',
    'copy',
    'mozilla-cfx-xpi',
    'crx'
  ]);

  grunt.registerTask('beta', [
    'webstore_upload:beta'
  ]);

  grunt.registerTask('release', 'Bump, build and release.', function(type) {
    grunt.task.run([
      'bump-only:' + (type || 'patch'),
      'build',
      'crx:both',
      'webstore_upload:release',
      'bump-commit'
    ]);
  });

  grunt.registerTask('travis', ['build']);

};
