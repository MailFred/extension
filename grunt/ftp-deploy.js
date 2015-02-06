module.exports = function(grunt) {
    'use strict';

    var ff = grunt.config('shared.firefox');

    return {
        'firefox-release': {
            auth: {
                host: 'ftp.mailfred.de',
                port: 21,
                authKey: 'firefox'
            },
            src: ff.path,
            dest: '/firefox',
            forceVerbose: true,
            exclusions: [
                '**/*.xpi!' + ff.file
            ]
        }
    };
};
