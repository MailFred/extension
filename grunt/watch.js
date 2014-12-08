module.exports = function (grunt, options) {
  'use strict';

  var config = {
    "options": {
      "interrupt": true
    },
    "shared.static": {
      "files": [
        'shared/**',
        '!shared/{css,js}/**'
      ],
      "tasks": [
        "copy:shared.static"
      ]
    },
    "shared.styles": {
      "files": [
        "shared/css/*.less"
      ],
      "tasks": [
        "less:shared",
        "copy:shared.styles"
      ]
    }
  };

  ['chrome', 'firefox', 'shared'].forEach(function(target) {
    config[target + '.scripts'] = {
      "files": [
        target + "/js/src/*.coffee"
      ],
      "tasks": [
        "coffee:" + target,
        "uglify:" + target
      ]
    };
  });

  config["shared.scripts"].tasks.push("copy:shared.scripts");

  return config;
};
