gulp = require 'gulp'
gutil = require 'gulp-util'

coffeelint = require 'gulp-coffeelint'
coffee = require 'gulp-coffee'
uglify = require 'gulp-uglify'
del = require 'del'
runSequence = require 'run-sequence'
ngAnnotate = require 'gulp-ng-annotate'
docco = require 'gulp-docco'
rename = require 'gulp-rename'
pushDocs = require 'gulp-gh-pages'


# CONFIG ---------------------------------------------------------

isProd = gutil.env.type is 'prod'

sources =
  coffee: 'src/*.coffee'
  docs: 'docs/**/*'

# dev and prod will both go to dist for simplicity sake
destinations =
  js: 'dist'

# TASKS -------------------------------------------------------------

gulp.task 'lint', ->
  gulp.src(sources.coffee)
  .pipe(coffeelint())
  .pipe(coffeelint.reporter())

gulp.task 'docco', ->
  gulp.src(sources.coffee)
  .pipe(docco())
  .pipe(gulp.dest('docs'))

gulp.task 'src', ->
  gulp.src(sources.coffee)
  .pipe(coffee().on('error', gutil.log))
  .pipe(ngAnnotate())
  .pipe(gulp.dest(destinations.js))

gulp.task 'src:min', ->
  gulp.src(sources.coffee)
  .pipe(coffee().on('error', gutil.log))
  .pipe(ngAnnotate())
  .pipe(uglify())
  .pipe(rename( (file) ->
    file.extname = '.min.js'
    return
  ))
  .pipe(gulp.dest(destinations.js))

gulp.task 'clean', (cb) ->
  del(['dist/', 'docs/'], cb)

gulp.task 'push-docs', ->
  gulp.src(sources.docs)
  .pipe(pushDocs())

gulp.task 'build', ->
  runSequence 'clean', ['lint', 'docco', 'src:min', 'src']

gulp.task 'default', [
  'build'
]
