'use strict'
#
# G U L P  L O A D E R
# ====================
#
gulp = require('gulp')
gutil = require('gulp-util')  					# Gulp utilities
gulpIf = require('gulp-if')             # Run pipes conditionally
del = require('del')  						  	  # rm -rf
pug = require('pug')  						    	# Formerly known as JADE
gulpPug = require('gulp-pug')  					# Formerly known as JADE
filter = require('gulp-filter') 				# Filter for paths (using it to hide underscore folders)
sass = require('gulp-sass') 				  	# SASS
uglify = require('gulp-uglify') 				# For Javascript
imagemin = require('gulp-imagemin') 		# Image minify
notify = require('gulp-notify') 				# For pretty notifications
browserSync = require('browser-sync').create()
merge = require('merge-stream') 				# merge() command for tasks with multiple sources
cmq = require('gulp-group-css-media-queries') 	# Combines media queries

#
# C O N F I G
# ===========
config =
  # default paths
  sourceDir: 'app'
  outputDir: '.tmp'

  # environment variables (for production)
  production: gutil.env.production

#### Add these to config object later ###
# default paths
# sourceDir = 'app'
# outputDir = '.tmp'
#
# env = gutil.env.env
#
# if env == 'prod'
#   outputDir = 'dist'

# if env == 'dev'
# else

#
# G U L P  T A S K S
# ==================
#


# Clean output dir
gulp.task 'clean', ->
  del config.outputDir + '/**/*'


# Process HTML
gulp.task 'html', ->
  gulp.src(config.sourceDir + '/**/*.pug')
  # Filters out files and folders starting with underscore
  .pipe(filter((file) ->
    !/\/_/.test(file.path) and !/^_/.test(file.relative)
  ))
  .pipe(gulpPug(
    pug: pug
    basedir: config.sourceDir
    pretty: true))
  .pipe(gulp.dest(config.outputDir))
  .pipe notify(message: 'HTML task complete')


# Process styles
# gulp.task 'styles', [ 'cmq' ], ->
gulp.task 'styles', ->

  # SASS configuration parameters

  # Include paths to components
  sassConfig = includePaths: [
    'bower_components/bootstrap-sass/assets/stylesheets'
    'bower_components/sass-mq'
  ]
  sassConfig.outputStyle = 'map'

  # Compress stylesheets for production
  if config.production
    sassConfig.outputStyle = 'compressed'

  gulp.src(config.sourceDir + '/styles/**/*.{scss,sass}')
  .pipe(sass(sassConfig))
  .pipe(gulp.dest(config.outputDir + '/styles'))
  .pipe(browserSync.stream())
  .pipe notify(message: 'Styles task complete')


# Combine Media Queries
gulp.task 'cmq', ->
  gulp.src(config.outputDir + '/styles/**/*.css')
  .pipe(cmq()).pipe(gulp.dest(config.outputDir + '/styles'))
  .pipe notify(message: 'Media Queries Combined')


# Copy fonts
gulp.task 'fonts', ->
  gulp.src([ config.sourceDir + '/fonts/MonoSocialIconsFont-1.10.*' ])
  .pipe(gulp.dest(config.outputDir + '/fonts'))
  .pipe notify(message: 'Fonts task complete')


# Process scripts
gulp.task 'scripts', ->

  # Minify and copy all JavaScript (except vendor scripts)
  js = gulp.src(config.sourceDir + '/scripts/**/*.js')
  .pipe(uglify())
  .pipe(gulp.dest(config.outputDir + '/scripts'))
  
  # Copy vendor files
  vendor = gulp.src([])
  .pipe(gulp.dest(config.outputDir + '/scripts/vendor'))
  merge js, vendor


# Compress and minify images to reduce their file size
gulp.task 'images', ->
  gulp.src(config.sourceDir + '/**/*.{jpg,png,svg,ico}')
  .pipe(gulpIf(config.production, imagemin()))
  .pipe(gulp.dest(config.outputDir))
  .pipe notify(message: 'Images task complete')

#
# Watcher
# =======
#

gulp.task 'watch', ->
  gulp.watch(config.sourceDir + '/**/*.pug', [ 'html' ]).on 'change', browserSync.reload
  gulp.watch config.sourceDir + '/scripts/**/*.js', [ 'scripts' ]
  gulp.watch config.sourceDir + '/**/*.{jpg,png,svg,ico}', [ 'images' ]
  gulp.watch config.sourceDir + '/styles/**/*.{scss,sass}', [
    'styles'
    'cmq'
  ]
  gulp.watch config.sourceDir + '/fonts/**/*', [ 'fonts' ]
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
    server: config.outputDir
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