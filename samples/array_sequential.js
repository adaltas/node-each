
    var each = require('each');
    
    each( [{id: 1}, {id: 2}, {id: 3}] )
    .on('data', function(next, element, index) {
        console.log('element: ', element, '@', index);
        setTimeout(next, 500);
    })
    .on('error', function(err) {
        console.log(err.message);
    })
    .on('success', function() {
        console.log('Done');
    });
