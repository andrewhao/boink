// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var timestamps = null;

function countdown(expected) {
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
    console.log('delta from expected: ' + expected_time - now);
}

$(window).ready(function () {
    $('button#start-button').click(function(e) {

        $.get('time_now', null, function(data) {
            // Temp logging
            console.log("set_id is: "+data.set_id);
            console.log("timestamps are: "+data.timestamps);

            // Set global
            timestamps = data.timestamps;
            var time_now = (new Date()).getTime();
            var closest_ts = timestamps.pop();
            var ts_delta = closest_ts - time_now - 3000;
            
            console.log('delta is:' + ts_delta);

            while(timestamps.length > 0) {
                console.log('timestamps array is'+timestamps);
                // Start countdown
                setTimeout(function() {
                    countdown(closest_ts);
                }, ts_delta);
                closest_ts = timestamps.pop();
                ts_delta = closest_ts - time_now - 3000;
            }

        });
    });
});