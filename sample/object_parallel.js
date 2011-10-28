
    var each = require('each');
    
    // With an `end_callback` in `parallel` mode:
    
    each({
        id_1: 1,
        id_2: 2,
        id_3: 3
    }, true, function(key, value, next) {
        console.log('key: ', key);
        console.log('value: ', value);
        setTimeout(next, 500);
    }, function(){
        console.log('Done');
    });