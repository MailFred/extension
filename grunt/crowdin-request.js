/* global module, process, require, __dirname */
module.exports = function(grunt) {
    'use strict';

    var fs = require('fs');
    var path = require('path');
    var base = path.join(__dirname, '..');
    var dir = path.join(base, 'tmp/i18n');


    grunt.task.registerTask('copy-crowdin-files', function() {
        var done = this.async();

        fs.readdir(dir, function(err, files) {
            if (err) {
                grunt.fail.fatal(err);
                done(false);
                return;
            }
            var copied = 0;
            files
                .filter(function(language) {
                    return grunt.file.isDir(path.join(dir, language));
                })
                .forEach(function(language) {
                    grunt.file.recurse(path.join(dir, language), function callback(abspath, rootdir, subdir, filename) {
                        grunt.file.copy(abspath, path.join(base, subdir, filename));
                        copied++;
                    })
                });
            grunt.log.ok(copied + ' ' + grunt.util.pluralize(copied, 'file/files') + ' copied.');
            done(true);
        });
    });

    return {
        options: {
            'project-identifier': 'mailfred',
            'api-key': process.env.CROWDIN_API_KEY
        },
        download: {
            outputDir: dir
        }
    };
};
