module.exports = function(grunt) {

  var releasePath = "./build/<%= pkg.name %>-<%= manifest.version %>.zip";

  grunt.initConfig({
    shared: {
      releasePath: releasePath
    },
    pkg: grunt.file.readJSON('package.json'),
    manifest: grunt.file.readJSON('chrome/manifest.json'),
    firefoxPackage: grunt.file.readJSON('firefox/package.json')
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
    'build:sources',
    'copy',
    'env:ff',
    'mozilla-cfx-xpi',
    'crx'
  ]);

  grunt.registerTask('beta', [
    'webstore_upload:beta'
  ]);

  grunt.registerTask('release', 'Bump, build and release.', function(type) {
    grunt.task.run([
      'bump-only:' + (type || 'patch'),
      'build:all',
      'crx:both',
      'webstore_upload:release',
      'bump-commit'
    ]);
  });

  grunt.registerTask('travis', [
    'setup',
    'e2e:remote'
  ]);

  grunt.registerTask('setup', [
    'mozilla-addon-sdk'
  ]);

  grunt.registerTask('default', 'setup');


  grunt.registerTask("e2e:local", [
      'build:all',
      "protractor_webdriver:general",
      "protractor:firefox",
      "protractor:chrome"
  ]);

  grunt.registerTask("e2e:remote", [
    'build:all',
    "protractor:firefox.remote",
    "protractor:chrome.remote"
  ])
};
