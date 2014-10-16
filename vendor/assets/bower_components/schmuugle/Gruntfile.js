/* jshint node: true */

module.exports = function(grunt) {
  "use strict";

  // Project configuration.
  grunt.initConfig({

    // Metadata.
    pkg: grunt.file.readJSON('package.json'),
    banner: '/*!\n' +
      ' * Schmuugle v<%= pkg.version %> \n' +
      ' */\n',

    // Task configuration.
    jshint: {
      options: {
        jshintrc: 'js/.jshintrc'
      },
      src: {
        src: ['js/*.js']
      }
    },
    concat: {
      options: {
        banner: '<%= banner %>',
        stripBanners: false
      },
      schmuugle: {
        src: [
          'js/img_checkbox.js',
//          'js/multi_select.js'
        ],
        dest: 'dist/js/<%= pkg.name %>.js'
      }
    },

    uglify: {
      options: {
        banner: '<%= banner %>',
        report: 'min'
      },
      schmuugle: {
        src: ['<%= concat.schmuugle.dest %>'],
        dest: 'dist/js/<%= pkg.name %>.min.js'
      }
    },

    clean: {
      dist: ['dist']
    },

    recess: {
      options: {
        compile: true,
        banner: '<%= banner %>'
      },
      schmuugle: {
        src: ['less/schmuugle.less'],
        dest: 'dist/css/<%= pkg.name %>.css'
      },
      min: {
        options: {
          compress: true
        },
        src: ['less/schmuugle.less'],
        dest: 'dist/css/<%= pkg.name %>.min.css'
      }
    },

    copy: {
//      font-awesome, bootstrap css , js -> dis
//      fonts: {
//        expand: true,
//        src: ["fonts/*"],
//        dest: 'dist/'
//      }
    },

    connect: {
      server: {
        options: {
          port: 3000,
          base: '.'
        }
      }
    },

    validation: {
//      options: {
//        reset: true
//      },
//      files: {
//        src: ["examples/**/*.html"]
//      }
    },

    watch: {
      src: {
        files: '<%= jshint.src.src %>',
        tasks: ['concat', 'uglify']
      },
      recess: {
        files: 'less/*.less',
        tasks: ['recess']
      }
    }
  });


  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-connect');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-html-validation');
//  grunt.loadNpmTasks('grunt-jekyll');
  grunt.loadNpmTasks('grunt-recess');
//  grunt.loadNpmTasks('browserstack-runner');

  // Docs HTML validation task
  grunt.registerTask('validate-html', ['validation']);

  // Test task.
  var testSubtasks = ['dist-css', 'validate-html'];

//  grunt.registerTask('jshint', ['jshint']);
  grunt.registerTask('test', testSubtasks);

  grunt.registerTask('dist-js', ['concat', 'uglify']);

  // CSS distribution task.
  grunt.registerTask('dist-css', ['recess']);


  // Full distribution task.
  grunt.registerTask('dist', ['clean', 'dist-css', 'dist-fonts', 'dist-js']);

  // Default task.
  grunt.registerTask('default', ['test', 'dist']);

};
