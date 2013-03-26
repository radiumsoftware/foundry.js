module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-simple-mocha');

  grunt.initConfig({
    clean: {
      all: ['build', 'dist']
    },

    coffee: {
      compile: {
        files: {
          'build/foundry.js': 'src/foundry.coffee',
          'build/adapters/null_adapter.js': 'src/adapters/null_adapter.coffee',
        }
      },
    },

    concat: {
      dist: {
        src: ['build/foundry.js', 'build/adapters/null_adapter.js'],
        dest: 'dist/foundry.js'
      }
    },

    uglify: {
      dist: {
        files: {
          "dist/foundry.min.js": "dist/foundry.js"
        }
      }
    },

    simplemocha: {
      options: {
        timeout: 3000,
        ui: 'bdd',
        reporter: 'dot'
      },

      all: { 
        src: 'test/**/*_test.coffee'
      }
    }
  });

  grunt.registerTask('build', ['clean', 'coffee', 'concat', 'uglify']);

  grunt.registerTask('test', ['build', 'simplemocha:all']);

  grunt.registerTask('default', 'test');
};
