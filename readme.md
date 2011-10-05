
<pre style="font-family:courier">
 _   _           _        ______           _     
| \ | |         | |      |  ____|         | |    
|  \| | ___   __| | ___  | |__   __ _  ___| |__  
| . ` |/ _ \ / _` |/ _ \ |  __| / _` |/ __| '_ \ 
| |\  | (_) | (_| |  __/ | |___| (_| | (__| | | |
|_| \_|\___/ \__,_|\___| |______\__,_|\___|_| |_| New BSD License
</pre>

Node Each is a single elegant function to iterate asynchronously over elements 
both in `sequential`, `parallel` and `concurrent` mode.

The `each` function signature is: `each(subject, parallel=boolean||number, iterator_callback, [end_callback])`.

-   `subject`   
    The first argument is the subject to iterate. It can be an array, an object or 
    any other types in which case the behavior is similar to the one of an array.

-   `parallel`   
    The second argument is optional and indicate wether or not you want the 
    iteration to run in `sequential`, `parallel` or `concurrent` mode. In 
    `sequential` mode, each callback is called once the previous callback is 
    completed after calling its `next` argument. In `parallel` mode, all the 
    callbacks are called at the same time. In `concurrent` mode, only a defined 
    number of callbacks are run in parallel.   
    If `parallel` is a number, the mode is `concurrent`.
    If `parallel` is true, the mode is `parallel`.
    Otherwise, the mode is `sequential`.

-   `iterator_callback`   
    The third argument is a callback function function called for each iterated 
    element. The number of arguments depends on the subject type. For an object, 
    the first argument will be the key, the second argument the key associated 
    value and the third argument the `next` callback used to notifiy the end of 
    the callback.

-   `end_callback`
    The fourth argument is optional and is a callback called when the iteration 
    isfinished.

If no `end_callback` is provided, the `iterator_callback` will be called one more 
time with the `next` argument set to null.

Traversing an array
-------------------

Without an `end_callback` in `sequential` mode:

```javascript
    var each = require('each');
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
```

With an `end_callback` in `parallel` mode:

```javascript
    var each = require('each');
    each([
        {id: 1},
        {id: 2},
        {id: 3}
    ], true, function(id, next) {
        if(next === null) return done();
        console.log('id: ', id);
        setTimeout(next, 500);
    }, function(){
        console.log('Done');
    });
```

Traversing an object
--------------------

Without an `end_callback` in `sequential` mode:

```javascript
    var each = require('each');
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
```

With an `end_callback` in `parallel` mode:

```javascript
    var each = require('each');
    each({
        id_1: 1,
        id_2: 2,
        id_3: 3
    }, true, function(key, value, next) {
        if(next === null) return done();
        console.log('key: ', key);
        console.log('value: ', value);
        setTimeout(next, 500);
    }, function(){
        console.log('Done');
    });
```

Installing
----------

Via git (or downloaded tarball):

```bash
    git clone http://github.com/wdavidw/node-each.git
```

Then, simply copy or link the project inside a discoverable Node directory (node_modules).

Via [npm](http://github.com/isaacs/npm):

```bash
    $ npm install each
```
