module.exports = function(grunt) {
    'use strict';
    var shared = grunt.config('shared');

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
            "privateKey": "certs/chrome/key.pem"
        }
    };
};
