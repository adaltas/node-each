
    var each = require('each');
    
    // Without an `end_callback` in `chained` mode:
    
    each([
        {id: 1},
        {id: 2},
        {id: 3}
    ], function(id, next) {
        if(next === null) return done();
        console.log('id: ', id);
        setTimeout(next, 500);
    });
    function done(){
        console.log('Done');
    }