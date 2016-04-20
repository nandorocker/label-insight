// Error Handling with Plumber
var onError = function(err) {
    console.log(err);
}

//
// G U L P  L O A D E R
//
var gulp 		 = require('gulp'),
	gutil 		 = require('gulp-util'),
	del 		 = require('del'), // to delete folders
	pug 		 = require('pug'),
	gulpPug 	 = require('gulp-pug'),
	sass 		 = require('gulp-sass'),
	uglify 		 = require('gulp-uglify'),
	imagemin	 = require('gulp-imagemin'), // Image minify
	notify		 = require('gulp-notify'),
	browserSync	 = require('browser-sync').create(),
	sourcemaps	 = require('gulp-sourcemaps');

//
// V A R I A B L E S
//

// Sets environment variables through gulp-util
// To invoke: $ gulp --env=prod
var env = gutil.env.env;
var sourceDir = 'app';
var outputDir = '.tmp';

if (env === 'prod') {
	outputDir = 'dist';
	console.log("hello");
}
if (env === 'dev') {
}

//
// G U L P  T A S K S
//

// Clean output dir first
gulp.task('clean', function() {
	return del([
		outputDir + '/**/*'
	]);
});

// Process HTML
gulp.task('html', function(){
	return gulp.src(sourceDir + '/**/*.pug')
		.pipe(gulpPug({
			pug: pug,
			pretty: true
		}))
		.pipe(gulp.dest(outputDir))
		.pipe(notify({ message: 'HTML task complete' }));
});

// Process styles
gulp.task('styles', function(){
	var config = {};

	if (env === 'prod') {
		config.outputStyle = 'compressed';
	}

	if (env === 'dev') {
		config.outputStyle = 'map';
	}

	return gulp
		.src(sourceDir + '/styles/**/*.{scss,sass}')
		.pipe(sass(config))
		.pipe(gulp.dest(outputDir + '/styles'))
		.pipe(browserSync.stream())
		.pipe(notify({ message: 'Styles task complete' }));
});

// Process scripts
gulp.task('scripts', ['clean'], function() {
  // Minify and copy all JavaScript (except vendor scripts)
  gulp.src(sourceDir + "/scripts/**/*.js")
    .pipe(uglify())
    .pipe(gulp.dest(outputDir + '/scripts'));

  // Copy vendor files
  gulp.src([
	  	'bower_components/slicknav/dist/jquery.slicknav.min.js',	// Slicknav
	  	'bower_components/jquery/dist/jquery.min.js'				// Jquery
  	])
    .pipe(gulp.dest(outputDir + '/scripts/vendor'));
});

// Compress and minify images to reduce their file size
gulp.task('images', function() {
	var imgSrc = sourceDir + '/images/**/*',
		imgDst = outputDir + '/images';

	return gulp.src(imgSrc)
		// .pipe(imagemin())
		.pipe(gulp.dest(imgDst))
		.pipe(notify({ message: 'Images task complete' }));
});

// Gulp Watch
gulp.task('watch', function() {
	gulp.watch(sourceDir + '/**/*.pug', ['html']);
	gulp.watch(sourceDir + '/styles/**/*.{scss,sass}', ['styles']);
	gulp.watch(sourceDir + '/**/*.{jpg,png,svg,ico}');
});

// Development Server
gulp.task('serve', ['build'], function() {
	browserSync.init({
		server: '.tmp'
	});

	gulp.watch(sourceDir + '/**/*.{jpg,png,svg,ico}', ['images']);
	gulp.watch(sourceDir + '/styles/**/*.{scss,sass}', ['styles']);
	gulp.watch(sourceDir + '/**/*.pug', ['html']).on('change', browserSync.reload);
});

// Build
gulp.task('build', ['clean', 'html', 'scripts', 'images', 'styles']);

// Default task
gulp.task('default', ['serve']);