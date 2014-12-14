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
    },
    "firefox.main": {
      "files": [
          "firefox/lib/main.js"
      ],
      "tasks": [
        'mozilla-cfx-xpi',
        'shell:update-xpi'
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

  var sharedTasks = config["shared.scripts"].tasks;
  sharedTasks.push("copy:shared.scripts");
  sharedTasks.push('mozilla-cfx-xpi');
  sharedTasks.push('shell:update-xpi');


  return config;
};
