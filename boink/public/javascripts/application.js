// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var PHOTO_MARGIN = 50; // Margin for the composite photo per side
var WINDOW_WIDTH = $(window).width();
var WINDOW_HEIGHT = $(window).height();

// Current app state 
var State = {
    photoset: [],
    set_id: null,
    current_frame_idx: 0,
    zoomed: null
};

function PhotoView() {
    this.container = $('#viewport');
    this.canvas = new Raphael('viewport', $(window).width(), $(window).height());
    this.frames = this.canvas.set(); // List of SVG images (photos).
    this.all = this.canvas.set();
    
    this.photoBorder = 0;
    this.compositeDim = null;
    this.frameDim = null;
    this.compositeOrigin = null;
    this.compositeCenter = null;
}

PhotoView.prototype.toString = function() {
    ret = [];
    ret.push("Composite photo is: " + this.all[0].attr('width') + 'x' + this.all[0].attr('height'));
    ret.push("Frame photo is: " + this.frameDim.w + 'x' + this.frameDim.h);
    return ret.join('\n');
}

PhotoView.prototype.render = function() {
    var w = WINDOW_WIDTH - PHOTO_MARGIN;
    var h = WINDOW_HEIGHT - PHOTO_MARGIN;
    this.compositeDim = CameraUtils.scale4x6(w, h);
    this.compositeOrigin = {
        x: (WINDOW_WIDTH - this.compositeDim.w) / 2,
        y: (WINDOW_HEIGHT - this.compositeDim.h) / 2
    };
    this.compositeCenter = {
        x: this.compositeOrigin.x + (this.compositeDim.w/2),
        y: this.compositeOrigin.y + (this.compositeDim.h/2)
    }
    var r = this.canvas.rect(this.compositeOrigin.x, this.compositeOrigin.y, this.compositeDim.w, this.compositeDim.h);
    
    r.attr({'fill': 'white'});
    
    this.all.push(r);
    
    // Scale the photo padding too
    this.photoBorder = this.compositeDim.w / 50;

    //upper x
    var frame_x = this.compositeOrigin.x + this.photoBorder;
    var frame_y = this.compositeOrigin.y + this.photoBorder;
    this.frameDim = {
        w: (this.compositeDim.w - (3*this.photoBorder))/2,
        h: (this.compositeDim.h - (3*this.photoBorder))/2
    };
    var frame = this.canvas.rect(frame_x, frame_y, this.frameDim.w, this.frameDim.h);
    //var frame = this.canvas.image(null, frame_x, frame_y, frame_w, frame_h);
    frame.attr({'fill': 'black'});
    this.frames.push(frame);
    this.all.push(frame);
    
    frame = frame.clone();
    frame.translate(this.frameDim.w + this.photoBorder, 0);
    this.frames.push(frame);
    this.all.push(frame);
    
    frame = frame.clone();
    frame.translate(-(this.frameDim.w + this.photoBorder), this.frameDim.h + this.photoBorder);
    this.frames.push(frame);
    this.all.push(frame);
    
    frame = frame.clone();
    frame.translate(this.frameDim.w + this.photoBorder, 0);
    this.frames.push(frame);
    this.all.push(frame);
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
                view.all.push(img);
                
                // Store img svg obj in frames
                view.frames[i] = img;
           }
       }
    });
}

/**
 * zoomFrame
 */
PhotoView.prototype.zoomFrame = function(idx, dir) {
    var view = this;
    var composite = this.all[idx];
    var frame = this.frames[idx];
    var frameX = frame.attr('x');
    var frameW = frame.attr('width');
    var frameY = frame.attr('y');
    var frameH = frame.attr('height');
    var centerX = frameX + frameW/2;
    var centerY = frameY + frameH/2;
    
    // delta to translate to.
    var dx = this.compositeCenter.x - centerX;
    var dy = this.compositeCenter.y - centerY;
    var scaleFactor = this.compositeDim.w / this.frameDim.w;
        
    if (State.zoomed) {
        scaleFactor = 1;
        dx = -State.zoomed.dx;
        dy = -State.zoomed.dy;
        view.all.animate({
            'scale': [scaleFactor, scaleFactor, view.compositeCenter.x, view.compositeCenter.y].join(','),        
        }, 1000, function() {
            view.all.animate({
                'translation': dx+','+dy
            }, 1000)
        });
        
    } else {
        view.all.animate({
            'translation': dx+','+dy
        }, 1000, function() {
            view.all.animate({
                'scale': [scaleFactor, scaleFactor, view.compositeCenter.x, view.compositeCenter.y].join(','),
            }, 1000)
        });
        
    }
    
    if (State.zoomed !== null) {
        State.zoomed = null;
    } else {
        State.zoomed = {
            dx: dx,
            dy: dy,
            scaleFactor: scaleFactor
        };
    }
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
    $('button#zoom-button').click(function(e) {
       p.zoomFrame(State.current_frame_idx);
    });
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

