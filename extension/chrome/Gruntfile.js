module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    uglify: {
      options: {
        sourceMap: true,
        sourceMapIncludeSources: true,
      },
      build: {
        files: [{
          expand: true,
          cwd: 'js/build',
          src: '*.js',
          dest: 'js/build',
          ext: '.min.js'
        }]
      }
    },

    coffee: {
      compile: {
        options: {
          sourceMap: true
        },
        expand: true,
        flatten: true,
        cwd: 'js/src',
        src: ['*.coffee'],
        dest: 'js/build',
        ext: '.js'
      }
    },

    less: {
      build: {
        files: {
          "css/styles.css": "css/styles.less"
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-less');

  grunt.registerTask('default', ['coffee:compile', 'uglify:build', 'less:build']);
  grunt.registerTask('travis', ['coffee:compile', 'less:build']);

};
