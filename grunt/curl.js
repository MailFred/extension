/* global require */
module.exports = function(grunt) {
    'use strict';

    var semver = require('semver');
    var jqueryVersion = semver.clean(grunt.file.readJSON('bower.json').dependencies.jquery);

    return {
        // we need the jquery SHA-256 hash to match https://github.com/mozilla/amo-validator/blob/master/validator/testcases/hashes.txt
        // otherwise the extension gets rejected from the mozilla add-on store
        amo: {
            dest: 'firefox/data/shared/bower_components/jquery/dist/jquery.min.js',
            src: 'http://code.jquery.com/jquery-' + jqueryVersion + '.min.js'
        }
    }
};
