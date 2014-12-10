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
        '**/*',
        '!{css,js}/**'
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
        scripts('firefox')
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
