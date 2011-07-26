// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(window).ready(function () {
    $('button#start-button').click(function(e) {
        $.get('start_snap', null, function(data) {
            // Temp logging
            console.log("set_id is: "+data.set_id);
            console.log("timestamps are: "+data.timestamps);
            
            // TODO/andrew Implementation
        })
    });
})