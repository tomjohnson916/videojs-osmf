'use strict';

var childProcess = require('child_process');
var flexSdk = require('flex-sdk');
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
        path: 'http://127.0.0.1:<%= connect.dev.options.port %>/example.html',
        app: 'Google Chrome'
      }
    },
    mxmlc: {
      videojs: {
        osmf: {
          swf: {
            src: ['src/as/VideoJSOSMF.as'],
            dest: 'dist/videojs-osmf.swf'
          }
        }
      }
    },
    watch: {
      as: {
        files: ['src/as/**/*.as'],
        tasks: ['mxmlc']
      },
      js: {
        files: ['src/**/*.js'],
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
      },
      build: {
        tasks: ['shell:echo'],
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
  grunt.registerTask('dev', 'Launching Dev Environment', 'concurrent:dev');
  grunt.registerMultiTask('mxmlc', 'Compiling the SWF', function () {
    var pkg, cmdLineOpts;

    pkg = grunt.file.readJSON('package.json');

    cmdLineOpts = [];
    cmdLineOpts.push('-output');
    cmdLineOpts.push(this.data.osmf.swf.dest);
    cmdLineOpts.push('-define=CONFIG::version, "' + pkg.version + '"');

    /*
    TODO - Add support for conditional compiling

    if(grunt.option('useAkamai') === true) {
      cmdLineOpts.push('-library-path=node_modules/akamai/hdcore.swc');
    }
    */

    cmdLineOpts.push('--');
    cmdLineOpts.push.apply(cmdLineOpts, this.data.osmf.swf.src);

    childProcess.execFile(flexSdk.bin.mxmlc, cmdLineOpts, function(err) {
      if (err) {
        grunt.log.error('Error Creating SWF');
        grunt.log.error(err.toString());
      }
    });
  });
};
