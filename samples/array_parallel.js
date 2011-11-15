
    var each = require('each');
    
    each( [{id: 1}, {id: 2}, {id: 3}], true )
    .on('data', function(next, id) {
        console.log('id: ', id);
        setTimeout(next, 500);
    })
    .on('error', function(err, errors){
        console.log(err.message);
        errors.forEach(function(error){
            console.log('  '+error.message);
        });
    })
    .on('end', function(){
        console.log('Done');
    });