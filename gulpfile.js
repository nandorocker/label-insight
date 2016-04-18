var gulp       = require('gulp'),
	changed    = require('gulp-changes'),
	compass    = require('gulp-compass'),
	concat     = require('gulp-concat'),
	imagemin   = require('gulp-imagemin'),
	jshint     = require('gulp-jshint'),
	notify     = require('gulp-notify'),
	plumber    = require('gulp-plumber'),
	stripDebug = require('gulp-strip-debug'),
	uglify     = require('gulp-uglify'),
	liveReload = require('gulp-live-reload');

// Gulp plumber error handler
var onError = function(err) {
	console.log(err);
}

// Lets us type "gulp" on the command line and run all of our tasks
gulp.task('default', ['copyfiles', 'images', 'jshint', 'scripts', 'styles', 'watch']);

// Copy fonts from a module outside of our project (like Bower)
gulp.task('copyfiles', function() {
	gulp.src('./source_directory/**/*.{ttf,woff,eof,svg}')
	.pipe(gulp.dest('./fonts'));
});

// Compress and minify images to reduce their file size
gulp.task('images', function() {
	var imgSrc = './src/images/**/*',
		imgDst = './images';

	return gulp.src(imgSrc)
		.pipe(plumber({
			errorHandler: onError
		}))
		.pipe(changed(imgDst))
		.pipe(imagemin())
		.pipe(gulp.dest(imgDst))
		.pipe(notify({ message: 'Images task complete' }));
});

// Hint all of our custom developed Javascript to make sure things are clean
gulp.task('jshint', function() {
	return gulp.src('./src/scripts/*.js')
	.pipe(plumber({
		errorHandler: onError
	}))
	.pipe(jshint())
	.pipe(jshint.reporter('default'))
	.pipe(notify({ message: 'JS Hinting task complete' }));
});

// Combine/Minify/Clean Javascript files
gulp.task('scripts', function() {
	return gulp.src('./src/scripts/*.js')
		.pipe(plumber({
			errorHandler: onError
		}))
		.pipe(concat('app.min.js'))
		.pipe(stripDebug())
		.pipe(uglify())
		.pipe(gulp.dest('./js/'))
		.pipe(notify({ message: 'Scripts task complete' }));
});

// Combine and minify Sass/Compass stylesheets
gulp.task('styles', function() {
	return gulp.src('./src/sass/*.scss')
		.pipe(plumber({
			errorHandler: onError
		}))
		.pipe(compass({
			config_file: './config.rb',
			css: './css',
			sass: './sass'
		}))
		.pipe(gulp.dest('./css'))
		.pipe(notify({ message: 'Styles task complete' }));
});

// This handles watching and running tasks as well as telling our LiveReload server to refresh things
gulp.task('watch', function() {
	// Check for modifications in particular directories

	// Whenever a stylesheet is changed, recompile
	gulp.watch('./src/sass/**/*.scss', ['styles']);

	// If user-developed Javascript is modified, re-run our hinter and scripts tasks
	gulp.watch('./src/scripts/**/*.js', ['jshint', 'scripts']);

	// If an image is modified, run our images task to compress images
	gulp.watch('./src/images/**/*', ['images']);

	// Create a LiveReload server
	var server = liveReload();

	// Watch any file for a change in the 'src' folder and reload as required
	gulp.watch(['./src/**']).on('change', function(file) {
		server.changed(file.path);
	})
});