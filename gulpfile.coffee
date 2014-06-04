gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
uglify = require 'gulp-uglify'
coffeelint = require 'gulp-coffeelint'
rename = require 'gulp-rename'
plumber = require 'gulp-plumber'
clean = require 'gulp-clean'

paths =
  src: './src/**/*.coffee'
  test: './test/**/*.coffee'
  build: './lib'

# Define the gulp tasks
gulp.task 'clean', ->
  gulp.src(paths.build, {read: false})
    .pipe(clean())

gulp.task 'lint', ->
  gulp.src([paths.src, paths.test], {base: './src'})
    .pipe(coffeelint())
    .pipe(coffeelint.reporter())

gulp.task 'test', ->
  require('child_process').spawn('mocha', { stdio: 'inherit' });

gulp.task 'publish', ['clean'], ->
  gulp.src(paths.src)
    .pipe(plumber({
        errorHandler: (err)->
          gutil.beep()
          console.log(err)
      }))
    .pipe(coffee(bare: true).on('error', gutil.log))
    .pipe(rename 'odysseus.js')
    .pipe(gulp.dest paths.build)
    .pipe(uglify())
    .pipe(rename 'odysseus.min.js')
    .pipe(gulp.dest paths.build)

gulp.task 'watch', ->
  gulp.watch paths.src, ['lint']
  gulp.watch paths.test, ['lint']

gulp.task 'default', ['watch']

