module.exports = function (grunt, options) {
  'use strict';
  var config = {
    "options": {
      "sourceMap": true,
      "sourceMapIncludeSources": true
    },
    "shared": {
      "files": [
        {
          "expand": true,
          "cwd": "shared/js/build",
          "src": ["*.js", "!*.min.js"],
          "dest": "shared/js/build",
          "ext": ".min.js"
        }
      ]
    }
  };

  ['chrome', 'firefox'].forEach(function(target) {
    var path = target + "/lib/js/build";
    config[target] = {
      "files": [
        {
          "expand": true,
          "cwd": path,
          "src": ["*.js", "!*.min.js"],
          "dest": path,
          "ext": ".min.js"
        }
      ]
    };
  });

  return config;
};
