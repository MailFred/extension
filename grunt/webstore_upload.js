module.exports = function (grunt, options) {
  'use strict';
  var shared = grunt.config('shared');

  return {
    "accounts": {
      "support@mailfred.de": {
        "publish": true
      }
    },
    "extensions": {
      "beta": {
        "account": "support@mailfred.de",
        "appID": "hcedpboddcjnggmdpbgdnlllkhmjjeil",
        "zip": shared.releasePath
      },
      "release": {
        "account": "support@mailfred.de",
        "appID": "lijahkfnlmaikbppnbjeelhihaklhoim",
        "zip": shared.releasePath
      }
    }
  };
};
