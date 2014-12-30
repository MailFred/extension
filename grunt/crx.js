/* global require */
module.exports = function(grunt) {
    'use strict';
    var shared = grunt.config('shared');
    var path = require('path');

    return {
        "both": {
            "src": [
                "./chrome/**/*",
                '!./chrome/lib/js/src/**',
                '!./chrome/lib/js/build/**/*.{js,map}',
                './chrome/lib/js/build/**/*.min.js'
            ],
            "dest": "./build",
            "zipDest": shared.releasePath,
            options: {
                privateKey: path.join(__dirname, "../certs/chrome/key.pem")
            }
        }
    };
};
