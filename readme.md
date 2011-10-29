
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

The `each` function signature is: `each(subject, mode=boolean||number, iterator_callback, [end_callback])`.

-   `subject`   
    The first argument is the subject to iterate. It can be an array, an object or 
    any other types in which case the behavior is similar to the one of an array.

-   `mode`   
    The second argument is optional and indicate wether or not you want the 
    iteration to run in `sequential`, `parallel` or `concurrent` mode. See below
    for more details about the different modes.

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

Defining a mode
---------------

-   `sequential`   
    Mode is `false`, default if no mode is defined.
    Callbacks are chained meaning each callback is called once the previous 
    callback is completed (after calling the `next` argument).
-   `parallel`
    Mode is `true`.
    All the callbacks are called at the same time and run in parallel.
-   `concurrent`
    Mode is an integer.
    Only the defined number of callbacks is run in parallel.

Dealing with errors
-------------------

Error are declared to each by calling `next` with an error object as its first
argument. The behavior is aligned with Node conventions. Throwing an error won't
be handled by each.

When an `end_callback` is defined, it will recieve an error object as its first
argument. When no `end_callback` is defined, the `next` argument is swiched to 
an error object instead of a function.

In `sequential` mode, the error object is the one passed to the `next` 
callback. In `parallel` and `concurrent` modes, a new error object is created 
because multiple errors may be thrown at the same time. For conveniency, it 
contains an `errors` key which is an array of all the errors sent to the 
`next` callback.

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
        if(next instanceof Error) return console.log(err.message);
        if(!next) return console.log('Done');
        console.log('id: ', id);
        setTimeout(next, 500);
    });
```

With an `end_callback` in `parallel` mode:

```javascript
    var each = require('each');
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
        if(next instanceof Error) return console.log(err.message);
        if(!next) return console.log('Done');
        console.log('key: ', key);
        console.log('value: ', value);
        setTimeout(next, 500);
    });
```

With an `end_callback` in `parallel` mode:

```javascript
    var each = require('each');
    each({
        id_1: 1,
        id_2: 2,
        id_3: 3
    }, true, function(key, value, next) {
        console.log('key: ', key);
        console.log('value: ', value);
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
