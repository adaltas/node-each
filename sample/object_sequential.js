
    var each = require('each');
    
    // Without an `end_callback` in `chained` mode:
    
    each({
        id_1: 1,
        id_2: 2,
        id_3: 3
    }, function(key, value, next) {
        if(next instanceof Error) return console.log('Error '+err.message);
        if(!next) return console.log('Done');
        console.log('key: ', key);
        console.log('value: ', value);
        setTimeout(next, 500);
    });
