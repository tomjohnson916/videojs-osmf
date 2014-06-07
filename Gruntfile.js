module.exports = function(grunt) {
  grunt.initConfig({
    connect: {
      dev: {
        options: {
          port: 9999,
          keepalive: true
        }
      }
    },
    watch: {
      files: ['**/*'],
      tasks: ['jshint']
    },
    jshint: {
      all: ['./src/**/*.js']
    },
    concat: {
      dist: {
        src: ['./src/**/*.js'],
        dest: 'dist/videojs-osmf.js'
      }
    },
    uglify : {
      all : {
        files: {
          'dist/videojs-osmf.min.js' : [
            'dist/videojs-osmf.js'
          ]
        }
      }
    }
  });

  // Require needed grunt-modules
  grunt.loadNpmTasks('grunt-contrib-connect');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-concat');

  // Define tasks
  grunt.registerTask('default', ['jshint', 'concat', 'uglify']);
};
