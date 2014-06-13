coffee      = require 'gulp-coffee'
clean       = require 'gulp-clean'
runSequence = require 'run-sequence'

module.exports = (gulp) ->
  gulp.task 'build', ->
    runSequence 'build:clean', 'build:compile'

  gulp.task 'build:clean', ->
    gulp.src('dist/*', read: false)
    .pipe(clean())

  gulp.task 'build:compile', ->
    gulp.src('src/diff.coffee')
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest('dist'))
