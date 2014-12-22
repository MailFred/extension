module.exports = function (grunt, options) {
  'use strict';

  var config = {
    "options": {
      "sourceMap": true
    },
    "shared": {
      "expand": true,
      "flatten": true,
      "cwd": "shared/js/src",
      "src": [
        "*.coffee"
      ],
      "dest": "shared/js/build",
      "ext": ".js"
    }
  };

  ['chrome', 'firefox'].forEach(function(target) {
    config[target] = {
      "expand": true,
      "flatten": true,
      "cwd": target + "/lib/js/src",
      "src": [
        "*.coffee"
      ],
      "dest": target + "/lib/js/build",
      "ext": ".js"
    };
  });

  return config;
};
