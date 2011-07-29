// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var PHOTO_PADDING = 50; // Padding for the grand photo per side
var WINDOW_WIDTH = $(window).width();
var WINDOW_HEIGHT = $(window).height();
var PHOTO_PADDING = 50; // Padding on the sides and down the middle of the photo 2x2.

// Given a max w and h bounds, return the dimensions
// of the largest 4x6 rect that will fit within.
function scale4x6(maxw, maxh) {
    var s0 = 6/4; // width / height
    var s1 = maxw/maxh;
    
    // Then the width is longer. Use the shorter side (height)
    if (s0 <= s1) {
        return {w: maxh * 6/4, h: maxh};
    } else {
        return {w: maxw, h: maxw * 4/6}
    }
}

function PhotoView() {
    this.container = $('#viewport');
    this.canvas = new Raphael('viewport', $(window).width(), $(window).height());
    this.frames = []; // List of SVG images (photos).
}
PhotoView.prototype.render = function() {
    var w = WINDOW_WIDTH - PHOTO_PADDING;
    var h = WINDOW_HEIGHT - PHOTO_PADDING;
    var scaled = scale4x6(w, h);
    var r = this.canvas.rect((WINDOW_WIDTH - scaled.w) / 2, (WINDOW_HEIGHT - scaled.h) / 2, scaled.w, scaled.h);
    r.attr({'fill': 'white'});
    

}

function countdown(expected) {
    console.log('countdown with expected time of: '+expected);
    var counter = 3;
    var countdownTimer = setInterval(function() {
        console.log(counter);
        if (counter == 1) {
            console.log('expected to snap: ' + expected);
            clearInterval(countdownTimer);
            setTimeout(function() {snap(expected);}, 1000);
        }
        counter -= 1;
    }, 1000);
}

function snap(expected_time) {
    var now = (new Date()).getTime();
    console.log('snap at ' + now);
    console.log('delta from expected: ' + (expected_time - now));
}

$(window).ready(function () {
    $('button#start-button').click(function(e) {
        $.get('time_now', null, function(data) {
            // Temp logging
            console.log("set_id is: "+data.set_id);
            console.log("timestamps are: "+data.timestamps);

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
                    countdown(expect);
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

