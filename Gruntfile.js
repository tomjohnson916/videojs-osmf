'use strict';

var os = require('os');
var interfaces = os.networkInterfaces();
var ipAddress;

for (var k in interfaces) {
  for (var k2 in interfaces[k]) {
    var address = interfaces[k][k2];
    if (address.family == 'IPv4' && !address.internal) {
      ipAddress = address.address;
      break;
    }
  }
}

module.exports = function(grunt) {
  grunt.initConfig({
    ipAddress: ipAddress,
    pkg: grunt.file.readJSON('package.json'),
    swf: {
      src: 'src/as/VideoJSOSMF.as',
      dest: 'dist/videojs-osmf.swf'
    },
    shell: {
      mxmlc: {
        command: './compiler/bin/mxmlc -define+=CONFIG::FLASH_10_1,true -define+=CONFIG::LOGGING,true -define+=CONFIG::PLATFORM,true -define+=CONFIG::MOCK,false -library-path+=libs/ <%= swf.src %> -o <%= swf.dest %>',
        options: {
          callback: function (err, stdout, stderr, cb) {
            if (err) {
              grunt.log.error(stderr);
            }
            grunt.log.writeln(stdout);
            cb();
          }
        }
      }
    },
    connect: {
      dev: {
        options: {
          port: 1234,
          keepalive: true
        }
      }
    },
    open : {
      dev : {
        path: 'http://localhost:<%= connect.dev.options.port %>/example.html',
        app: 'Google Chrome'
      }
    },
    watch: {
      as: {
        files: ['src/as/**/*.*'],
        tasks: ['shell:mxmlc']
      },
      grunt: {
        files: ['Gruntfile.js'],
        tasks: ['shell:mxmlc']
      },
      js: {
        files: ['src/**/*.js', 'Gruntfile.js'],
        tasks: ['jshint']
      }
    },
    jshint: {
      all: ['src/**/*.js']
    },
    concat: {
      dist: {
        src: ['src/**/*.js'],
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
    },
    concurrent: {
      dev: {
        tasks: ['connect:dev', 'open', 'watch'],
        options: {
          logConcurrentOutput: true
        }
      }
    }
  });

  // Load Grunt tasks.
  require('load-grunt-tasks')(grunt);

  // Default task.
  grunt.registerTask('default', ['clean', 'jshint', 'qunit', 'concat', 'uglify']);
  grunt.registerTask('dev', 'Launching Dev Environment', ['build','concurrent:dev']);
  grunt.registerTask('build', ['shell:mxmlc']);

};
