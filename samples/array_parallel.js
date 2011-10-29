
    var each = require('each');
    
    // With an `end_callback` in `parallel` mode:
    
    each([
        {id: 1},
        {id: 2},
        {id: 3}
    ], true, function(id, next) {
        console.log('id: ', id);
        setTimeout(next, 500);
    }, function(err){
        if(err){
            console.log(err.message);
            err.errors.forEach(function(error){
                console.log('  '+error.message);
            });
        }else{
            console.log('Done');
        }
    });