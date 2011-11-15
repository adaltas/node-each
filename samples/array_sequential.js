
    var each = require('each');
    
    each( [{id: 1}, {id: 2}, {id: 3}] )
    .on('data', function(next, id) {
        console.log('id: ', id);
        setTimeout(next, 500);
    })
    .on('error', function(err) {
        console.log(err.message);
    })
    .on('end', function() {
        console.log('Done');
    });
