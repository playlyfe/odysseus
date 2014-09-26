gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
uglify = require 'gulp-uglify'
coffeelint = require 'gulp-coffeelint'
rename = require 'gulp-rename'
plumber = require 'gulp-plumber'
rimraf = require 'gulp-rimraf'
header = require 'gulp-header'
bump = require 'gulp-bump'
runSequence = require 'run-sequence'

banner =
  long: """
  /**
   * <%= pkg.name %> - <%= pkg.description %>
   * version: <%= pkg.version %>
   * repository: <%= pkg.homepage %>
   * license: <%= pkg.license %>
   * author: <%= pkg.author.name %> (<%= pkg.author.email %>)
  **/

  """
  short: "// <%= pkg.name %> v<%= pkg.version %>\n"

paths =
  src: './src/**/*.coffee'
  test: './test/**/*.coffee'
  build: './lib'

# Define the gulp tasks
gulp.task 'clean', ->
  gulp.src(paths.build, {read: false})
    .pipe(rimraf())

gulp.task 'lint', ->
  gulp.src([paths.src, paths.test], {base: './src'})
    .pipe(coffeelint())
    .pipe(coffeelint.reporter())

gulp.task 'build', ['clean'], (cb) ->
  pkg = require './package.json'
  gutil.log gutil.colors.black.bgYellow(" Run `publish` after build ")
  gulp.src(paths.src)
    .pipe(plumber({
        errorHandler: (err)->
          gutil.beep()
          console.log(err)
      }))
    .pipe(coffee(bare: true).on('error', gutil.log))
    .pipe(rename 'odysseus.js')
    .pipe(header(banner.long, {pkg: pkg}))
    .pipe(gulp.dest paths.build)
    .pipe(uglify())
    .pipe(rename 'odysseus.min.js')
    .pipe(header(banner.short, {pkg: pkg}))
    .pipe(gulp.dest paths.build)

gulp.task 'bump', ->
  gulp.src(['./bower.json', './package.json'])
    .pipe(bump())  # Bump version
    .pipe(gulp.dest './')

gulp.task 'watch', ->
  gulp.watch paths.src, ['lint']
  gulp.watch paths.test, ['lint']

gulp.task 'default', ['watch']
gulp.task 'publish', ->
  runSequence 'bump', 'build', ->
    gutil.log gutil.colors.black.bgCyan(" Run `npm publish` to push to npm ")
