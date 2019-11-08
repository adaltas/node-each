[![Build Status](https://secure.travis-ci.org/adaltas/node-each.png)](http://travis-ci.org/adaltas/node-each)

Node Each is a single elegant function to iterate asynchronously over elements 
both in `sequential`, `parallel` and `concurrent` mode. It is a
powerful and mature library.

Main functionalities include:

* Iterate over arrays and objects
* Control the number of executed handler functions in parallel
* asynchronous and synchronous supported handler functions
* Run array elements and object key/pairs multiple times
* Multiple call detection in callback
* Full test coverage
* Zero dependencies

## Usage

### Asynchronous and concurrent Mode

```javascript
each( [{id: 1}, {id: 2}, {id: 3}] )
.parralel(2)
.call( function(element, index, callback){
  console.log('element: ', element, '@', index);
  setTimeout(callback, 500);
})
.next( function(err){
  console.log(err ? err.message : 'Done');
});
```

### Synchronous and sequential Mode

```javascript
each( [{id: 1}, {id: 2}, {id: 3}] )
.sync()
.call( function(element, index){
  console.log('element: ', element, '@', index);
})
.next( function(err){
  console.log(err ? err.message : 'Done');
});
```

## Installation

Via git (or downloaded tarball):

```bash
git clone http://github.com/wdavidw/node-each.git
```

Then, simply copy or link the project inside a discoverable Node directory 
(eg './node_modules').

Via [npm](http://github.com/isaacs/npm):

```bash
npm install each
```

Note:

* version above 0.8.0 renamed then to next
* versions above 0.2.x, changed arguments of the item callback

## API

The `each` function signature is: `each(subject, [options])`.

- `subject` (array|object, required)   
  The subject to iterate. It is usually an array or an object.
  Inserting a number or a string will behave like an array of one
  element and inserting null or undefined won't iterate over any
  element.
- `options` (object, optional)   
  Options may contain concurrency, repeat, sync, times. The option `concurrency`
  may be "false" for sequential, "true" for parallel and a number for concurrent
  mode. For other options, see below their associated function.

The return object is an instance of `EventEmitter`.

The following functions are available:

- `call(function)`   
  The function handler to call for each iterated element. Provided
  arguments depends on the subject type and the number of arguments
  defined in the callback. More information below.
- `close()`   
  Stop the iteration, garanty that no item will be emitted after it is called.
- `end()`   
  Stop the iteration, garanty that no item will be emitted after it is
  called.
- `error(function)`   
  Called only if an error occured. The iteration will be stopped on
  error meaning no `item` event will be called other than the ones
  already provisionned. The callback function is called with one
  argument, the error object. See the section `dealing with errors`
  for more information.
- `next(function)`   
  Called only once all the items have been handled. In case there was
  no error function previously set, the first argument is the error
  object if any. The following argument is the number of traversed
  items as the second argument. In case of an error, this number
  correspond to the number of item callbacks which called next.
- `parallel(mode)`   
  The first argument is optional and indicate wether or not you want
  the iteration to run in `sequential`, `parallel` or `concurrent`
  mode. See below for more details about the different modes.
- `promise`   
  Return a Javascript promise called on error or completion.
- `push(item)` or `push(key, value)`
  Add array elements or key/value pairs at the end of iteration.
- `repeat()`   
  Repeat operation multiple times once all elements have been called, see
  `times`.
- `sync()`   
  Run callbacks in synchronous mode, no next callback are provided,
  may throw an error.
- `times()`   
  Repeat operation multiple times before passing to the next element,
  see `repeat`.
- `unshift(items)`   
  Add array elements or key/value pairs at the begining of the iteration,
  just after the last executed element.
- `write(items)`   
  Alias of `push`.

The following properties are available:

- `paused`   
  Indicate the state of the current event emitter.
- `readable`   
  Indicate if the stream will emit more event.
- `started`  
  Number of callbacks which have been called.
- `done`  
  Number of callbacks which have finished.
- `total`   
  Total of registered elements.

## Parallelization modes

- `sequential`   
  Parallel is `false` or set to `1`, default if no parallel mode is defined.
  Callbacks are chained meaning each callback is called once the previous 
  callback is completed (after calling the `next` function argument).
- `parallel`   
  Parallel is `true`. In asynchronous mode, the handler function is called at
  the same time for all elements and run in parallel
- `concurrent`   
  Parallel is a number. Similar with the parallel mode, in asynchronous mode,
  the number of parallel execution of the handler function is garanteed to not
  exceed the user provided value.

## Callback arguments in call handlers

The last argument, `callback`, is a function to call once your action has
complete. It may be called with an error instance to  trigger the `error` event.
An example worth a tousand words,  see the code examples below for usage.

Inside array iteration, callback signature is `function([value], [index], callback)`.

```javascript
each([])
// 1 argument
.call(function(callback){})
// 2 arguments
.call(function(value, callback){})
// 3 arguments
.call(function(value, index, callback){})
// done
.then(function(){})
```

Inside object iteration, callback signature is `function([key], [value], [counter], callback)`.

```javascript
each({})
// 1 argument
.call(function(callback){})
// 2 arguments
.call(function(value, callback){})
// 3 arguments
.call(function(key, value, callback){})
// 4 arguments
.call(function(key, value, counter, callback){})
// done
.then(function(){})
```

## Dealing with errors

Error are provided by calling the `callback` function argument in the `item` event with an error 
object as its first argument.

```javascript
each( ['a', 'b'] )
.call(function(element, next) {
  setImmediate( () => {
    next(new Error("Catchme"))
  })
})
.next(function(err){
  assert.equal(err.message, "Catchme")
});
```

It is also possible to throw an Error as long as the error is attach to the function:

```javascript
each( ['a', 'b'] )
.call(function(element, next) {
  throw new Error("Catchme")
  // Not ok:
  // setImmediate( () => {
  //   throw new Error("Catchme")
  // })
})
.next(function(err){
  assert.equal(err.message, "Catchme")
});
```

The error will be provided to the `next` function handler unless an `error` function handler is defined before.

```javascript
each( ['a', 'b'] )
.call(function(element, next) {
  setImmediate( () => {
    next(new Error("Catchme"))
  })
})
.error(function(err){
  assert.equal(err.message, "Catchme")
});
.next(function(err){
  assert.equal(err, undefined)
});
```

In case of parallel and concurrent mode, the currently running callbacks are not
canceled but no new element will be processed.

The `error` argument is always an instance of error. However, it defers
according to the execution mode. In `sequential` mode, it is always the error
that was thrown inside the failed callback. In `parallel` and `concurrent`
modes, there may be more than one event thrown asynchronously. In such case, the
error has the generic message such as `Multiple errors $count` and the property
`.errors` is an array giving access to each individual error.

```javascript
each( ['a', 'b'] )
.parralel(true)
.call(function(element, next) {
  setImmediate( () => {
    next(new Error(`Error ${element}`))
  })
})
.error(function(err){
  assert.equal(err.message, `Multiple errors 2`)
  const messages = err.errors.map( e => e.message )
  assert.equal(messages, ["Catchme a", "Catchme b"])
});
```

Note, it is possible to know [the number of successful handler functions](https://github.com/adaltas/node-each/blob/master/samples/error_count_succeed.js) in the `next` event by subtracting the number of executed callbacks provided as the second argument to the number of errors.

```javascript
each([1, 2, 3])
.parallel(true)
.call(function(val, callback){
  setImmediate( () => {
    callback( val % 2 && new Error("Invalid") )
  })
})
.next(function(err, count) {
  const succeed = count - err.errors.length
  assert.equal(succeed, 1)
})
```

## Traversing an array

In `sequential` mode:

```javascript
var each = require('each');
each( [{id: 1}, {id: 2}, {id: 3}] )
.call( function(element, index, callback){
  setImmediate(callback);
})
.next( function(err){
  console.log(err ? err.message : 'success');
})
```

In `parallel` mode:

```javascript
var each = require('each');
each( [{id: 1}, {id: 2}, {id: 3}] )
.parallel( true )
.call(function(element, index, callback) {
  console.log('element: ', element, '@', index);
  setTimeout(callback, 500);
})
.next(function(err){
  console.log(err ? err.message : 'success');
});
```

In `concurrent` mode (4 parallel executions):

```javascript
var each = require('each');
each( [{id: 1}, {id: 2}, {id: 3}] )
.parallel( 4 )
.call(function(element, index, callback) {
  console.log('element: ', element, '@', index);
  setTimeout(callback, 500);
})
.next(function(err){
  console.log(err ? err.message : 'success');
});
```

## Traversing an object

In `sequential` mode:

```javascript
var each = require('each');
each( {id_1: 1, id_2: 2, id_3: 3} )
.call(function(key, value, callback) {
  console.log('key: ', key);
  console.log('value: ', value);
  setTimeout(callback, 500);
})
.next(function(err) {
  console.log(err ? err.message : 'success');
});
```

In `concurrent` mode with 2 parallels executions

```javascript
var each = require('each');
each( {id_1: 1, id_2: 2, id_3: 3} )
.parallel( 2 )
.call(function(key, value, callback) {
  console.log('key: ', key);
  console.log('value: ', value);
  setTimeout(callback, 500);
})
.next(function(err){
  console.log(err ? err.message : 'success');
});
```

## Manual Throttle

Use `pause` and `resume` functions to throttle the iteration.

## Repetition with `times` and `repeat`

With the addition of the `times` and `repeat` functions, you may traverse an
array or call a function multiple times. Note, you can not use those two
functions at the same time.

We first implemented this functionality while doing performance assessment and
needing to repeat a same set of metrics multiple times. The following sample
will call 3 times the function `doSomeMetrics` with the same arguments.

```javascript
each(['a', 'b', 'c', 'd'])
.times(3)
.call(function(id, callback){
  setImmediate(function(){
    process.stdout.write(id)
    callback()
  })
})
.next(function(){
  console.log('done');
});
```

The generated sequence is 'aaabbbcccddd'. In the same way, you could replace `times` by 
`repeat` and in such case, the generated sequence would have been `abcdabcdabcd`.

It is also possible to use `times` and `repeat` without providing any data. Here's how:

```javascript
count = 0
each()
.times(3)
.call(function(callback){
  console.log(count++);
})
.next(function(){
  console.log('total:' + count);
});
```

## Multiple call detection in callback

An error will be throw with the message "Multiple call detected" if the `callback` argument in the `item` callback is called multiple times. However, if `end` event has already been thrown, the only way to catch the error is by registering to the "uncaughtException" event of `process`.

## Examples

Node Each comes with a few example, all present in the "samples" folder. Here's how you may run each of them :

```bash
node samples/array_concurrent.js
node samples/array_parallel.js
node samples/array_sequential.js
node samples/object_concurrent.js
node samples/object_sequential.js
node samples/readable_stream.js
```

Tests are executed with mocha. To install it, simple run `npm install`, it will install
mocha and its dependencies in your project "node_modules" directory.

```bash
make test
```
