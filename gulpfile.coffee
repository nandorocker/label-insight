'use strict'
#
# G U L P  L O A D E R
# ====================
#
gulp = require('gulp')
gutil = require('gulp-util')  					# Gulp utilities
del = require('del')  							# rm -rf
pug = require('pug')  							# Formerly known as JADE
gulpPug = require('gulp-pug')  					# Formerly known as JADE
filter = require('gulp-filter') 				# Filter for paths (using it to hide underscore folders)
sass = require('gulp-sass') 					# SASS
uglify = require('gulp-uglify') 				# For Javascript
imagemin = require('gulp-imagemin') 			# Image minify
notify = require('gulp-notify') 				# For pretty notifications
browserSync = require('browser-sync').create()
merge = require('merge-stream') 				# merge() command for tasks with multiple sources
cmq = require('gulp-group-css-media-queries') 	# Combines media queries

#
# V A R I A B L E S
# =================
#
# Environment Vars
# ================
# Sets environment variables through gulp-util
# To invoke: $ gulp --env=prod
env = gutil.env.env

sourceDir = 'app'
outputDir = '.tmp'

if env == 'prod'
  outputDir = 'dist'

if env == 'dev'
else

#
# G U L P  T A S K S
# ==================
#


# Clean output dir
gulp.task 'clean', ->
  del outputDir + '/**/*'


# Process HTML
gulp.task 'html', ->
  gulp.src(sourceDir + '/**/*.pug').pipe(filter((file) ->
    !/\/_/.test(file.path) and !/^_/.test(file.relative)
  )).pipe(gulpPug(
    pug: pug
    basedir: sourceDir
    pretty: true)).pipe(gulp.dest(outputDir)).pipe notify(message: 'HTML task complete')


# Process styles
gulp.task 'styles', [ 'cmq' ], ->
  # SASS configuration parameters
  config = includePaths: [
    'bower_components/bootstrap-sass/assets/stylesheets'
    'bower_components/sass-mq'
  ]

  if env == 'prod'
    config.outputStyle = 'compressed'
  if env == 'dev'
    config.outputStyle = 'map'

  gulp.src(sourceDir + '/styles/**/*.{scss,sass}').pipe(sass(config)).pipe(gulp.dest(outputDir + '/styles')).pipe(browserSync.stream()).pipe notify(message: 'Styles task complete')


# Combine Media Queries
gulp.task 'cmq', ->
  gulp.src(outputDir + '/styles/**/*.css').pipe(cmq()).pipe(gulp.dest(outputDir + '/styles')).pipe notify(message: 'Media Queries Combined')


# Copy fonts
gulp.task 'fonts', ->
  gulp.src([ sourceDir + '/fonts/MonoSocialIconsFont-1.10.*' ]).pipe(gulp.dest(outputDir + '/fonts')).pipe notify(message: 'Fonts task complete')


# Process scripts
gulp.task 'scripts', ->

  # Minify and copy all JavaScript (except vendor scripts)
  js = gulp.src(sourceDir + '/scripts/**/*.js').pipe(uglify()).pipe(gulp.dest(outputDir + '/scripts'))
  
  # Copy vendor files
  vendor = gulp.src([]).pipe(gulp.dest(outputDir + '/scripts/vendor'))
  merge js, vendor


# Compress and minify images to reduce their file size
gulp.task 'images', ->
  gulp.src(sourceDir + '/**/*.{jpg,png,svg,ico}').pipe(imagemin()).pipe(gulp.dest(outputDir)).pipe notify(message: 'Images task complete')

#
# Watcher
# =======
#

gulp.task 'watch', ->
  gulp.watch(sourceDir + '/**/*.pug', [ 'html' ]).on 'change', browserSync.reload
  gulp.watch sourceDir + '/scripts/**/*.js', [ 'scripts' ]
  gulp.watch sourceDir + '/**/*.{jpg,png,svg,ico}', [ 'images' ]
  gulp.watch sourceDir + '/styles/**/*.{scss,sass}', [
    'styles'
    'cmq'
  ]
  gulp.watch sourceDir + '/fonts/**/*', [ 'fonts' ]
  return

# Gulp restart when gulpfile.js or config.js files are changed
spawn = require('child_process').spawn
gulp.task 'watch:gulp', ->
  p = undefined
  gulp.watch [
    'gulpfile.coffee'
  ], ->
    if p
      p.kill()
    p = spawn('gulp', [ 'build' ], stdio: 'inherit')
    return
  return

# Development Server
gulp.task 'serve', [ 'build' ], (done) ->
  browserSync.init {
    open: false
    port: 9000
    server: outputDir
  }, done
  return

# Build
gulp.task 'build', [ 'clean' ], ->
  gulp.start [
    'html'
    'scripts'
    'images'
    'styles'
    'fonts'
  ]

# Default task
gulp.task 'default', [
  'serve'
  'watch'
  'watch:gulp'
]