
    var each = require('each');
    
    var eacher = each( {id_1: 1, id_2: 2, id_3: 3} )
    .parallel( 10 )
    .on('item', function(next, key, value) {
        if(value === 1){
            eacher.pause()
            setTimeout(function(){
                eacher.resume()
                next()
            }, 500);
        }else{
            eacher.pause()
            setTimeout(function(){
                eacher.resume()
            }, 500);
            next()
        }
    })
    .on('end', function(){
        console.log('Done');
    });
