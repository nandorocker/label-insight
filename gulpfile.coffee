'use strict'
#
# G U L P  L O A D E R
# ====================
#
gulp = require('gulp')
gutil = require('gulp-util')  					# Gulp utilities
gulpIf = require('gulp-if')             # Run pipes conditionally
changed = require('gulp-changed')       # Only process tasks on changed files
del = require('del')  						  	  # rm -rf
sourcemaps = require('gulp-sourcemaps') # sourcemaps for CSS
plumber = require('gulp-plumber')       # plumber for error handling
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
autoprefixer = require('gulp-autoprefixer')     # Autoprefixes CSS for compatibility

#
# C O N F I G
# ===========
config =
  # environment variables (for production)
  production: gutil.env.production

  # default paths
  sourceDir: 'app'
  outputDir: '.tmp'

# set output dir to 'dist' for production
if config.production
  config.outputDir = 'dist'

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
  .pipe(plumber())

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

#
# Styles
#
gulp.task 'styles', ->
  # SASS configuration parameters
  opStyle = 'map'

  # Compress stylesheets for production
  if config.production
    opStyle = 'compressed'

  gulp.src(config.sourceDir + '/styles/**/*.{scss,sass}')
  .pipe(plumber())
  .pipe(sourcemaps.init())
  .pipe(sass({
    includePaths: [
      'bower_components/bootstrap-sass/assets/stylesheets'
      'bower_components/sass-mq'
    ]
    outputStyle: opStyle
    }))
  .pipe(gulpIf(config.production, cmq()))
  .pipe(gulpIf(config.production, autoprefixer()))
  .pipe(sourcemaps.write())
  .pipe(gulp.dest(config.outputDir + '/styles'))
  .pipe(browserSync.stream())
  .pipe notify(message: 'Styles task complete')

# Copy fonts
gulp.task 'fonts', ->
  gulp.src([ config.sourceDir + '/fonts/MonoSocialIconsFont-1.10.*' ])
  .pipe(plumber())
  .pipe(gulp.dest(config.outputDir + '/fonts'))
  .pipe notify(message: 'Fonts task complete')


# Process scripts
gulp.task 'scripts', ->

  # Minify and copy all JavaScript (except vendor scripts)
  js = gulp.src(config.sourceDir + '/scripts/**/*.js')
  .pipe(plumber())
  .pipe(gulpIf(config.production, uglify()))
  .pipe(gulp.dest(config.outputDir + '/scripts'))
  
  # Copy vendor files
  vendor = gulp.src([])
  .pipe(plumber())
  .pipe(gulp.dest(config.outputDir + '/scripts/vendor'))

  # Merge and return stream
  merge js, vendor


# Compress and minify images to reduce their file size
gulp.task 'images', ->
  gulp.src(config.sourceDir + '/**/*.{jpg,png,svg,ico}')
  .pipe(plumber())
  .pipe(changed(config.outputDir)) # Checks output dir for changes
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