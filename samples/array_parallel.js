
    var each = require('each');
    
    each( [{id: 1}, {id: 2}, {id: 3}], true )
    .on('data', function(next, element, index) {
        console.log('element: ', element, '@', index);
        setTimeout(next, 500);
    })
    .on('error', function(err, errors){
        console.log(err.message);
        errors.forEach(function(error){
            console.log('  '+error.message);
        });
    })
    .on('success', function(){
        console.log('Done');
    });