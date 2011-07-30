// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var PHOTO_MARGIN = 50; // Margin for the composite photo per side
var WINDOW_WIDTH = $(window).width();
var WINDOW_HEIGHT = $(window).height();

// Current app state 
var State = {
    photoset: [],
    set_id: null
};

function PhotoView() {
    this.container = $('#viewport');
    this.canvas = new Raphael('viewport', $(window).width(), $(window).height());
    this.frames = this.canvas.set(); // List of SVG images (photos).
}

PhotoView.prototype.render = function() {
    var w = WINDOW_WIDTH - PHOTO_MARGIN;
    var h = WINDOW_HEIGHT - PHOTO_MARGIN;
    var scaled = CameraUtils.scale4x6(w, h);
    var photo_x = (WINDOW_WIDTH - scaled.w) / 2;
    var photo_y = (WINDOW_HEIGHT - scaled.h) / 2;
    var r = this.canvas.rect(photo_x, photo_y, scaled.w, scaled.h);
    r.attr({'fill': 'white'});
    
    // Scale the photo padding too
    var PHOTO_BORDER = scaled.w / 50;

    //upper left
    var frame_x = photo_x + PHOTO_BORDER;
    var frame_y = photo_y + PHOTO_BORDER;
    var frame_w = (scaled.w - (3*PHOTO_BORDER))/2;
    var frame_h = (scaled.h - (3*PHOTO_BORDER))/2;
    var frame = this.canvas.rect(frame_x, frame_y, frame_w, frame_h);
    //var frame = this.canvas.image(null, frame_x, frame_y, frame_w, frame_h);
    frame.attr({'fill': 'black'});

    this.frames.push(frame);
    
    frame = frame.clone();
    frame.translate(frame_w + PHOTO_BORDER, 0);
    this.frames.push(frame);
    
    frame = frame.clone();
    frame.translate(-(frame_w + PHOTO_BORDER), frame_h + PHOTO_BORDER);
    this.frames.push(frame);
    
    frame = frame.clone();
    frame.translate(frame_w + PHOTO_BORDER, 0);
    this.frames.push(frame);
}

/**
 * Queries the server for updated photos
 */
PhotoView.prototype.updatePhotoSet = function(setId) {
    var view = this;
    $.get('photoset', {set_id: setId}, function(data) {
       var images = data.images;
       for (var i in images) {
           // New photo
           if (State.photoset[i] === undefined) {
               var image = images[i];
               State.photoset[i] = image;
               var oldframe = view.frames[i];

               // Draw new rect
               var img = view.canvas.image(image.url,
                    oldframe.attr('x'),
                    oldframe.attr('y'),
                    oldframe.attr('width'),
                    oldframe.attr('height'));
                // delete black rect
                oldframe.remove();
                
                // Store img svg obj in frames
                view.frames[i] = img;
           }
       }
    });
}

/**
 * Draws a modal with some text.
 */
PhotoView.prototype.modalMessage = function(text, persistTime, animateSpeed) {
    if (animateSpeed === undefined) { var animateSpeed = 200; }
    if (persistTime === undefined) { var persistTime = 500; }

    var sideLength = WINDOW_HEIGHT * 0.3;
    var x = (WINDOW_WIDTH - sideLength)/2;
    var y = (WINDOW_HEIGHT - sideLength)/2;
    var all = this.canvas.set();
    var r = this.canvas.rect(x, y,
        sideLength,
        sideLength,
        10);
    r.attr({'fill': 'black',
            'fill-opacity': 0.7,
            'stroke-color': 'white'});
    all.push(r);
    var txt = this.canvas.text(x + sideLength/2, y + sideLength/2, text);
    txt.attr({'fill': 'white',
        'font-size': '30',
        'font-weight': 'bold',
        'rotation': '-10'});
    all.push(txt);
    all.attr({'opacity': 0});
    all.animate({'opacity': 1, 'rotation': '0', 'scale': '1.5,1.5', 'font-size': '50'}, animateSpeed, '>');
    
    var t = setTimeout(function(all) {
        all.animate({'opacity': 0, 'scale': '1,1', 'rotation': '10', 'font-size': '30'},
            animateSpeed,
            '<',
            function() {
                // Delete nodes
                txt.remove();
                r.remove()
            });
    }, persistTime, all);
}

/**
 * A class of utility methods.
 */
function CameraUtils() {};

/**
 * Play the snap effect.
 */
CameraUtils.snap = function(expected_time) {
    var now = (new Date()).getTime();
    p.modalMessage('Cheese!');
    console.log('snap at ' + now);
    console.log('delta from expected: ' + (expected_time - now));
    p.updatePhotoSet();
}

/**
 * Given a max w and h bounds, return the dimensions
 * of the largest 4x6 rect that will fit within.
 */
CameraUtils.scale4x6 = function(maxw, maxh) {
    var s0 = 6/4; // width / height
    var s1 = maxw/maxh;
    
    // Then the width is longer. Use the shorter side (height)
    if (s0 <= s1) {
        return {w: maxh * 6/4, h: maxh};
    } else {
        return {w: maxw, h: maxw * 4/6}
    }
}

/**
 * Wrapper around snap()
 * Will count a 3-2-1 countdown before snap() is invoked.
 */
CameraUtils.countdown = function(expected) {
    console.log('countdown with expected time of: '+expected);
    var counter = 3;
    var countdownTimer = setInterval(function() {
        console.log(counter);
        p.modalMessage(counter);
        if (counter == 1) {
            console.log('expected to snap: ' + expected);
            clearInterval(countdownTimer);
            setTimeout(function() {
                CameraUtils.snap(expected);
            }, 1000);
        }
        counter -= 1;
    }, 1000);
}

$(window).ready(function () {
    $('button#start-button').click(function(e) {
        $.get('start_snap', null, function(data) {
            // Temp logging
            console.log("set_id is: "+data.set_id);
            console.log("timestamps are: "+data.timestamps);
            
            p.modalMessage('Ready?', 3000);

            // Set global
            var timestamps = data.timestamps;
            var time_now = (new Date()).getTime();
            var closest_ts = timestamps.pop();
            var ts_delta = closest_ts - time_now - 4000;
            
            console.log('delta is:' + ts_delta);

            while(timestamps.length > 0) {
                console.log('next expected time to snap at is:' + closest_ts);
                // Start countdown
                setTimeout(function(expect) {
                    CameraUtils.countdown(expect);
                }, ts_delta, closest_ts);
                closest_ts = timestamps.pop();
                ts_delta = closest_ts - time_now - 4000;
                console.log('delta is:' + ts_delta);
            }
        });
    });

    p = new PhotoView();
    p.render();

});

