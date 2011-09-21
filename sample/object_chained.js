
    var each = require('each');
    
    // Without an `end_callback` in `chained` mode:
    
    each({
        id_1: 1,
        id_2: 2,
        id_3: 3
    }, function(key, value, next) {
        if(next === null) return done();
        console.log('key: ', key);
        console.log('value: ', value);
        setTimeout(next, 500);
    });
    function done(){
        console.log('Done');
    }