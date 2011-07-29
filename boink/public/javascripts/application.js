// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

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
});