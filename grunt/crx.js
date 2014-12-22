module.exports = function (grunt) {
  'use strict';
  var shared = grunt.config('shared');

  return {
    "both": {
      "src": "./chrome",
      "dest": "./build",
      "zipDest": shared.releasePath,
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
  };
};
