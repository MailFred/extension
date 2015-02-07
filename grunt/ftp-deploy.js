/* global module, process */
module.exports = function(grunt) {
    'use strict';

    var ff = grunt.config('shared.firefox');

    return {
        'firefox-release': {
            auth: {
                host: 'ftp.mailfred.de',
                port: 21,
                authKey: 'firefox',
                authPath: process.env.FTP_DEPLOY_AUTH_PATH // may be undefined, uses the .ftppass file instead
            },
            src: ff.path,
            dest: '/firefox',
            forceVerbose: true,
            exclusions: [
                '**/*.xpi!' + ff.file // upload only the current xpi file
            ]
        }
    };
};
