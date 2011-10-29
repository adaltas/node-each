
    var each = require('each');
    
    // Without an `end_callback` in `chained` mode:
    
    each([
        {id: 1},
        {id: 2},
        {id: 3}
    ], function(id, next) {
        if(next instanceof Error) return console.log(err.message);
        if(!next) return console.log('Done');
        console.log('id: ', id);
        setTimeout(next, 500);
    });
