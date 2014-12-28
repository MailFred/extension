module.exports = function (grunt, options) {
  'use strict';

  function css(target) {
    return {
      "expand": true,
      "cwd": "shared/css/build",
      "src": [
        "**/*.css"
      ],
      "dest": target + "/data/shared/css"
    };
  }

  function src(target) {
    return {
      "expand": true,
      "cwd": "shared/js/src",
      "src": [
        "**/*.coffee"
      ],
      "dest": target + "/data/shared/js"
    };
  }

  function scripts(target) {
    return {
      "expand": true,
      "cwd": "shared/js/build",
      "src": [
        "**/*.{js,map}"
      ],
      "dest": target + "/data/shared/js"
    };
  }

  function statics(target) {
    return {
      "expand": true,
      "cwd": "shared",
      "src": [
          'images/**',
          'bower_components/eventr/build/eventr.min.js',
          'bower_components/gmailr/build/gmailr.min.js',
          'bower_components/gmailui/build/gmailui.min.js',
          'bower_components/headjs/dist/1.0.0/head.load.min.js',
          'bower_components/jquery/dist/jquery.min.js',
          'bower_components/jquery-deparam/jquery.ba-deparam.min.js',
          'bower_components/lodash/dist/lodash.min.js',
          'bower_components/lodash/dist/lodash.min.js',
          'bower_components/moment/min/moment.min.js',
          'bower_components/pikaday/pikaday.js',
          'bower_components/q/q.js',
          'bower_components/trackjs/tracker.js'
      ],
      "dest": target + "/data/shared"
    };
  }

  return {
    "options": {
      "timestamp": true
    },
    "shared.styles": {
      "files": [
        css('chrome'),
        css('firefox')
      ]
    },
    "shared.scripts": {
      "files": [
        scripts('chrome'),
        src('chrome'),
        scripts('firefox'),
        src('firefox')
      ]
    },
    "shared.static": {
      "files": [
        statics('chrome'),
        statics('firefox')
      ]
    }
  };
};
