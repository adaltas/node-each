
![Build Status](https://github.com/adaltas/node-each/actions/workflows/test.yml/badge.svg)

Each is a single elegant function to iterate over values both in `sequential`, `parallel` and `concurrent` mode. It is a powerful and mature library.

Main functionalities include:

* User-defined concurrency level: sequential, parallel or custom
* Iteration over a list of functions
* Iteration over a list of promise
* Iteration with any type of values handled by a user-defined function
* Full promise support
* Full test coverage
* Zero dependency

## Usage

Use your favorite package manager to install the `each` package:

```bash
npm install each
```

With ESM:

```js
import each from 'each';
```

With CommonJS:

```js
const each = require('each');
```

Notes:

* Version 2 is a complete rewrite based on promise.
* Version above 0.8.0 renamed then to next.
* Versions above 0.2.x, changed arguments of the callback.

## Initialisation

Signature is `each(...[items|options|concurrency|handler])`.

All arguments are optional and can be defined in any order.

Multiple items arrays are merged. Muliple options are merged as well.

- `items : array`   
  An array containing any type of value. Functions are executed and may return a promise. Promise are waiting to be resolved. Any other type is returned as is or pass as an argument of the `handler` function.
- `option : object`   
  An options object. See below for the list of supported options.
- `concurrency : boolean | integer`   
  A boolean or an integer value. Similar to setting the `concurrency` option property. Jump to the concurrency section below.
- `handler : function`   
  A function which take each item as an argument.

## Options

- `concurrency` (default `1`)   
  An integer value defining the number of function executed in parallel or a boolean value. Value `false` is converted to `1` where functions are executed sequentially. Value `true` is converted to `-1` where all functions run simultaneously.
- `fluent` (default `true`)
  Expose a fluent API where function may be chained.
- `pause` (default `false`)   
  Delay the execution of functions until `resume` is called.
- `relax` (default `false`)   
  Keep scheduling new functions when `call` is further executed.

## API

- `call`   
  Execute one or several items and return a promise with the resolved value. Unless the `fluent` option is `false`, it is also possible to chain additionnal functions.
- `end(error|options)`   
  Close the scheduler. No further items is allowed to register with `call`, or an error is thrown. It returns a promise which resolve once all previously scheduled items resolved. When `end` is called and each is in paused state, all paused items are resolved with `undefined` or an error if any.    
  Available options:
  - `error`   
    Reject the returned promise and every registered items which is not yet executed with an error. All scheduled items not yet executed are resolved with an error. In `relax` mode, only the promise returned by `end` is rejected with an error.
  - `force`   
    Skip the execution of registered items which are not yet scheduled for execution. The items resolve with undefined or the value associated with the error option.
- `error(error|null)`   
  Place the scheduler in an error state, all future registered items will be rejected. Use `null` to set the scheduler to a normal state. 
- `options`   
  Get all options with no argument, get a single option with one argument, and set the value of an option with two arguments.
- `pause`   
  Pause the scheduling of new functions, see the throttling section.
- `resume`   
  Resume the scheduling of new functions, see the throttling section. It returns a promise which resolve once all previously scheduled and paused items resolved.

## Iteration

### Iteration with any type of values

An other type is returned as is unless an handler function is defined.

Each iterates over any type of items. If no handler is defined, functions and and promises get a special treatment. Functions are executed and may return a promise and promises are resolved.

Here is a [quick example]('./samples/iteration.js'):

```js
const result = await each([
  // Item is a value
  'a',
  // Item is a function
  () => (new Promise((resolve) => resolve('b'))),
  // Item is a promise
  new Promise((resolve) => resolve('c')),
]);

assert.deepStrictEqual(
  result, 
  ['a', 'b', 'c']
);
```

Note, in the majority of cases, items arrays which does not contains function and promises are handled with an handler function.

### Iteration over a list of functions

Function are executed. Each handles both synchronuous and asynchronuous functions. In the latter case, function returns a promise and Each wait for its resolution.

Here a various way to [declare functions](./samples/iteration.functions.js):

```js
const result = await each([
  // Synchronous function
  function(){ return 'a'; },
  // Synchronous function with the fat arrow syntax
  () => 'b',
  // Asynchronous function
  () => (
    new Promise((resolve) => resolve('c'))
  ),
  // Asynchronous function which resolves after some delay
  () => (
    new Promise((resolve) => setTimeout (() => resolve('d')), 100)
  ),
]);

assert.deepStrictEqual(
  result, 
  ['a', 'b', 'c', 'd']
);
```

### Iteration over a list of promises

Promise are [waiting to be resolved](./samples/iteration.promise.js). When the concurrency level is set to sequential (default), the behavior is similar to `Promise.all`.

```js
const result = await each([
  // Instantly resolution
  new Promise((resolve) => resolve('a')),
  // Delayed resolution
  () => (
    new Promise((resolve) => setTimeout (() => resolve('b')), 100)
  ),
  // Instantly resolution
  new Promise((resolve) => resolve('c')),
]);

assert.deepStrictEqual(
  result, 
  ['a', 'b', 'c']
);
```

## Resolution order

Output order is consistent with input order. The value returned by a function or resolved by a promise is always returned in the same position as it was originally defined.

## Synchronous and asynchronous functions

A function can be an item to iterate or defined with the `handler` option. In both cases, the behavior is the same.

A function defined as an item:

```js
console.info(
  await each([() => 1])
)
```

A function handling an item:

```js
console.info(
  await each([1], (item) => item)
)
```

Handlers are called with the item as first argument and the index number as the second argument.

Synchronous functions return a value. Asynchronous functions return a Promise.

Here is a [synchronous handler](./samples/handler.synchronous.js) function:

```javascript
const result = await each(
  [{id: 'a'}, {id: 'b'}, {id: 'c'}, {id: 'd'}],
  (item, index) =>
    `${item.id}@${index}`
);

assert.deepStrictEqual(
  result, 
  ['a@0', 'b@1', 'c@2', 'd@3']
);
```

Here is a [asynchronous handler](./samples/handler.asynchronous.js) function:

```javascript
const result = await each(
  [{id: 'a'}, {id: 'b'}, {id: 'c'}, {id: 'd'}],
  (item, index) =>
    new Promise((resolve) =>
      setTimeout(resolve(`${item.id}@${index}`), 100)
    )
);

assert.deepStrictEqual(
  result, 
  ['a@0', 'b@1', 'c@2', 'd@3']
);
```

## Concurrency modes

- `sequential`   
  Concurrency is `false` or `1`. It is the default concurrency mode.
- `parallel`   
  Concurrency is `true` or `-1`. In asynchronous mode, all the items are executed in parallel.
- `concurrent`   
  Concurrency is a number. It defines the maximum number of function running in parallel at a given time.

### Sequential mode (default)

When the `concurrent` option is `undefined`, `false` or `1`, items are executed [in order one after the other](./samples/mode_concurrent.js).

```js
let running = 0;
const result = await each(
  [{id: 'a'}, {id: 'b'}, {id: 'c'}, {id: 'd'}],
  function(item, index) {
    running++;
    if(running !== 1){ throw Error('Invalid execution'); }
    return new Promise((resolve) =>
      setTimeout(() => {
        if(running !== 1){ throw Error('Invalid execution'); }
        running--;
        resolve(`${item.id}@${index}`);
      }, 100)
    );
  }
);

assert.deepStrictEqual(
  result, 
  ['a@0', 'b@1', 'c@2', 'd@3']
);
```

### Parallel mode

When the `concurrent` option is `true` or `-1`, items are all scheduled at the same time and [run in parallel](./samples/mode_parallel.js).

```js
let running = 0;
const result = await each(
  [{id: 'a'}, {id: 'b'}, {id: 'c'}, {id: 'd'}],
  true,
  function(item, index) {
    if(running !== index){ throw Error('Invalid execution'); }
    running++;
    return new Promise((resolve) =>
      setTimeout(() => {
        if(running !== 4-index){ throw Error('Invalid execution'); }
        running--;
        resolve(`${item.id}@${index}`);
      }, 100)
    );
  }
);

assert.deepStrictEqual(
  result, 
  ['a@0', 'b@1', 'c@2', 'd@3']
);
```

### Concurrent mode

When the `concurrent` mode is a value above `1`, the number of items running simultaneously is [cap to the `concurrent` value](./samples/mode_concurrent.js).

```js
let running = 0;
const result = await each(
  [{id: 'a'}, {id: 'b'}, {id: 'c'}, {id: 'd'}],
  2,
  function(item, index) {
    running++;
    if(running > 2){ throw Error('At most 2 running tasks'); }
    return new Promise((resolve, reject) =>
      setTimeout(() => {
        running--;
        if(running > 2){
          reject(Error('At most 2 running tasks'));
        } else {
          resolve(`${item.id}@${index}`);
        }
      }, 100)
    );
  }
);

assert.deepStrictEqual(
  result, 
  ['a@0', 'b@1', 'c@2', 'd@3']
);
```

## Manual throttling

Use `pause` and `resume` functions to throttle the iteration.

The `pause` option define the initial status. Its value default to `false`.

On pause, executed functions pursue their execution and no further function is
scheduled for execution.

When the iteration's state is paused, new scheduled items [will not resolve the returned promise](./samples/throttle.state.js) until the iteration is resumed.

```js
let state = 'paused';
const scheduler = each({pause: true});
scheduler.then(() =>
  assert.deepStrictEqual(
    state, 'resumed'
  )
);
setTimeout(() => {
  state = 'resumed';
  scheduler.resume();
}, 100);
```

The `resume` and `end` methods return a promise which [resolves once all the element's executions complete](./samples/throttle.resume.js). This is an example with `resume`.

```js
const stack = [];
const scheduler = each({pause: true});
scheduler.call(() =>
  new Promise((resolve) => {
    stack.push(1); resolve();
  })
);
scheduler.call(() =>
  new Promise((resolve) => {
    stack.push(2); resolve();
  })
);
setTimeout(async () => {
  // Before resume, not processing occurs
  assert.deepStrictEqual(
    stack, []
  );
  // Resume and wait for execution
  await scheduler.resume();
  // After resume, every element was processed
  assert.deepStrictEqual(
    stack, [1, 2]
  );
}, 100);
```

## Dealing with errors

The iteration is stopped on error.

With synchronous functions or when the concurrency mode is sequential, it behaves like `Promise.all`. On error, no additionnal function is scheduled for execution and the returned promise is rejected.

With asynchronous function executed concurrently, no additionnal functions are scheduled. Function which are already executed will resolve or reject their promise but the result is discarded.

Wether the items array is provided at initialisation or with the `call` function, the behavior is the same:

```js
try {
  await each(2).call([
    () => new Promise( (resolve) => 
      setImmediate( () => resolve('ok') )
    ),
    () => new Promise( (resolve, reject) => 
      setImmediate( () => reject(Error('Catchme')) )
    ),
    () => new Promise( (resolve) => 
      setImmediate( () => resolve('ok') )
    ),
  ])
} catch(error) {
  assert.equal(error.message, 'Catchme')
}
```

## Using the `fluent` option

The `fluent` option apply when using the `each().call` function. By default, it is enabled. The API is designed to allow [multiple calls to be chained](./samples/options.fluent.true.js) where the value of the last call is returned:

```js
const result = await each()
  .call(
    () => new Promise((resolve) => resolve(1))
  )
  .call(
    () => new Promise((resolve) => resolve(2))
  )
  .call(
    () => new Promise((resolve) => resolve(3))
  );

assert.strictEqual(result, 3)
```

The returned promise is enriched with the same functions as the promise returned by `each()`, thus exposing the [`each` API](#api).

Set the `fluent` option to `false` to [not overload the returned promise](./samples/options.fluent.false.js) with the each API:

```js
const promise = each({ fluent: false })
  .call(
    () => new Promise((resolve) => resolve(1))
  );

assert.strictEqual(promise.call, undefined);
assert.strictEqual(promise.options, undefined);
```

## Using the `pause` option

The `pause` set the initial mode of the scheduler. It is `false` by default. Setting the scheduler in pause mode implies calling `resume` to start the execution.

## Using the `relax` option

When the `relax` option is active, the internal scheduler permit the registration of new items with `call` even after an error.

It doesn't affect the processing of an `items` list. An error while handling one of the item will prevent additionnal execution and reject its promise. What it does is to provide the ability to register and execute new items with `call`.

This is an example with the [default behavior](./samples/options.relax.false.js):

```js
const scheduler = each();
const prom1 = scheduler.call(
  () => new Promise((resolve) => resolve(1))
);
const prom2 = scheduler.call(
  () => new Promise((resolve, reject) => reject(2))
);
const prom3 = scheduler.call(
  () => new Promise((resolve) => resolve(3))
);

const result = await Promise.allSettled([prom1, prom2, prom3]);
assert.deepStrictEqual(result, [
  {status: 'fulfilled', value: 1},
  {status: 'rejected', reason: 2},
  {status: 'rejected', reason: 2}
]);
```

This is an example with the [`relax` option in action](./samples/options.relax.true.js):

```js
const scheduler = each({relax: true});
const prom1 = scheduler.call(
  () => new Promise((resolve) => resolve(1))
);
const prom2 = scheduler.call(
  () => new Promise((resolve, reject) => reject(2))
);
const prom3 = scheduler.call(
  () => new Promise((resolve) => resolve(3))
);

const result = await Promise.allSettled([prom1, prom2, prom3]);
assert.deepStrictEqual(result, [
  {status: 'fulfilled', value: 1},
  {status: 'rejected', reason: 2},
  {status: 'fulfilled', value: 3}
]);
```

## Developers

Tests are executed with [Mocha](https://mochajs.org/). To install it, simple run `npm install`, it will install the `mocha` package and its dependencies.

```bash
npm run test
# Or
yarn run test
```

To automatically generate a new version and publish it:

```
yarn run release
```

Package publication is handled by the CI/CD with GitHub action.
