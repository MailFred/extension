/* global require */
module.exports = function(grunt) {
    'use strict';
  var releasePath = "./build/<%= pkg.name %>-<%= manifest.version %>.zip";

    var pkg = grunt.file.readJSON('package.json');
    var firefoxPackage = grunt.file.readJSON('firefox/package.json');

    var firefoxReleaseName = grunt.template.process("<%= name %>-<%= version %>.xpi", {
        data: firefoxPackage
    });

  grunt.initConfig({
    shared: {
      releasePath: releasePath,
        firefox: {
            path: './build/firefox/',
            file: firefoxReleaseName
        }
    },
    pkg: pkg,
    manifest: grunt.file.readJSON('chrome/manifest.json'),
    firefoxPackage: firefoxPackage
  });

  require('load-grunt-config')(grunt);

  grunt.registerTask('dev', [
      'build:sources',
      'copy',
      'watch'
  ]);

  grunt.registerTask('build:sources', [
    'coffee',
    'uglify',
    'less'
  ]);

  grunt.registerTask('build:all', [
    'clean:all',
    'i18n',
    'build:sources',
    'copy',
    'env:ff',
    'shell:update-max-version-cfx',
    'mozilla-cfx-xpi',
    'crx'
  ]);

  grunt.registerTask('beta', [
    'webstore_upload:beta'
  ]);

    grunt.registerTask('release:prepare', [
        'build:all',
        'shell:sign-xpi',
        'shell:update-rdf',
        'shell:generate-htaccess'
    ]);

    grunt.registerTask('release:upload:firefox', [
        'ftp-deploy:firefox-release'
    ]);
    grunt.registerTask('release:upload:chrome', [
        'webstore_upload:release'
    ]);

    grunt.registerTask('release', [
        'release:prepare',
        'release:upload:firefox',
        'release:upload:chrome'
    ]);

  grunt.registerTask('travis', [
    'setup',
    'e2e:remote'
  ]);

  grunt.registerTask('setup', [
    'mozilla-addon-sdk:latest',
    'curl:amo'
  ]);

  grunt.registerTask('default', 'setup');


  grunt.registerTask("e2e:local", [
      'build:all',
      "protractor_webdriver:general",
      "protractor:chrome",
      "protractor:firefox"
  ]);

  grunt.registerTask("e2e:remote", [
    'build:all',
    "protractor:firefox.remote",
    "protractor:chrome.remote"
  ]);

  grunt.registerTask('i18n', [
    'crowdin-request:download',
    'copy-crowdin-files'
  ]);
};
