// Error Handling with Plumber
var onError = function(err) {
    console.log(err);
}

var gulp 		= require('gulp'),
	gutil 		= require('gulp-util'),
	del 		= require('del'), // to delete folders
	pug 		= require('pug'),
	gulpPug 	= require('gulp-pug'),
	sass 		= require('gulp-sass'),
	browserify 	= require('browserify'), // Does some magic shit I don't understand
	source 		= require('vinyl-source-stream'), // Rquired for browserify
	buffer 		= require('vinyl-buffer'), // Rquired for browserify
	uglify 		= require('gulp-uglify'),
	imagemin	= require('gulp-imagemin'), // Image minify
	plumber		= require('gulp-plumber'), // Error Handling
	notify		= require('gulp-notify'),
	browserSync	= require('browser-sync').create();

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

// Clean output dir first
gulp.task('clean', function() {
	return del([
		outputDir + '/**/*'
	]);
});

// Process HTML
gulp.task('html', function(){
	return gulp.src(sourceDir + '/**/*.pug')
		.pipe(plumber({
			errorHandler: onError
		}))
		.pipe(gulpPug({
			pug: pug,
			pretty: true
		}))
		.pipe(gulp.dest(outputDir))
		.pipe(notify({ message: 'HTML task complete' }));
});

// Process scripts
gulp.task('js', function() {
	return browserify('./app/scripts/main.js', { debug: env !== 'production' })
		.bundle()
		.on('error', function (e) {
			gutil.log(e);
		})
		.pipe(plumber({
			errorHandler: onError
		}))
		.pipe(source('bundle.js'))
		.pipe(gulp.dest('.tmp/scripts'))
		.pipe(buffer())
		.pipe(env === 'prod' ? uglify() : gutil.noop())
		.pipe(gulp.dest(outputDir + '/scripts'))
		.pipe(notify({ message: 'JS task complete' }));
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

	return gulp.src(sourceDir + '/styles/**/*.{scss,sass}')
		.pipe(plumber({
			errorHandler: onError
		}))
		.pipe(sass(config))
		.pipe(gulp.dest(outputDir + '/styles'))
		.pipe(browserSync.stream())
		.pipe(notify({ message: 'Styles task complete' }));
});

// Compress and minify images to reduce their file size
gulp.task('images', function() {
	var imgSrc = sourceDir + '/images/**/*',
		imgDst = outputDir + '/images';

	return gulp.src(imgSrc)
		.pipe(plumber({
			errorHandler: onError
		}))
		.pipe(imagemin())
		.pipe(gulp.dest(imgDst))
		.pipe(notify({ message: 'Images task complete' }));
});

// Gulp Watch
gulp.task('watch', function() {
	gulp.watch(sourceDir + '/**/*.pug', ['html']);
	gulp.watch(sourceDir + '/scripts/**/*.js', ['js']);
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
	gulp.watch(sourceDir + '/scripts/**/*.js', ['js']);
	gulp.watch(sourceDir + '/**/*.pug', ['html']).on('change', browserSync.reload);
});

// Build
gulp.task('build', ['clean', 'html', 'js', 'images', 'styles']);

// Default task
gulp.task('default', ['serve']);