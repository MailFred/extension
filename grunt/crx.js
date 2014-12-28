module.exports = function (grunt) {
  'use strict';
  var shared = grunt.config('shared');

  return {
    "both": {
      "src": "./chrome/**/*",
      "dest": "./build",
      "zipDest": shared.releasePath,
      "privateKey": "key.pem"
    }
  };
};
