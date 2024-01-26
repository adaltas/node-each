
![Build Status](https://github.com/adaltas/node-each/actions/workflows/test.yml/badge.svg)

## About

Each is a single elegant function to iterate over values both in `sequential`, `parallel`, and `concurrent` mode. It is a powerful and mature library.

Main functionalities include:

* User-defined concurrency level: sequential, parallel, or custom
* Iteration over a list of functions
* Iteration over a list of promise
* Iteration with any type of values handled by a user-defined function
* Full promise support
* ESM package distributed as CommonJS, ESM, and UMD
* Full test coverage
* Zero dependency

## Getting started

### Installation

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

### Simple example

In its simplest form, Each is used as a single function, a bit like `Promise.all` or `Promise.allSettled` but, arguably, with more flexibility and easier to read.

This example defines list 3 items to process along the concurrency level and a [function hander](./docs/example.simple.handler.js) as it last argument:

```js
const stack = [];
const result = await each(
  [
    { message: "Is", timeout: 30},
    { message: "Gollum", timeout: 20},
    { message: "Around", timeout: 10},
  ],
  { concurrency: true },
  ({message, timeout}) =>
    new Promise((resolve) =>
      setTimeout(() => stack.push(message) && resolve(message), timeout)
    )
);

assert.equal(result.join(" "), "Is Gollum Around");
assert.equal(stack.join(" "), "Around Gollum Is");
```

It is equivalent to passing [items as functions](./docs/example.simple.items.js) without a function handler and with the concurrency level defined as `true`.

```js
const stack = [];
const result = await each(
  [
    () =>
      new Promise((resolve) => {
        setTimeout(() => stack.push("Is") && resolve("Is"), 30);
      }),
    () =>
      new Promise((resolve) => {
        setTimeout(() => stack.push("Gollum") && resolve("Gollum"), 20);
      }),
    () =>
      new Promise((resolve) => {
        setTimeout(() => stack.push("Around") && resolve("Around"), 10);
      }),
  ],
  true
);

assert.equal(result.join(" "), "Is Gollum Around");
assert.equal(stack.join(" "), "Around Gollum Is");
```

## Advanced usage

In its advanced form, Each is a scheduler with advanced functionalities to control the execution process.

```js
const scheduler = each({ concurrency: true });
const result = await Promise.all([
  scheduler.call([
    () => new Promise((resolve) => resolve(1)),
    () => new Promise((resolve) => resolve(2)),
  ]),
  scheduler.call([
    () => new Promise((resolve) => resolve(3)),
    () => new Promise((resolve) => resolve(4)),
  ]),
]);
assert.deepStrictEqual(result, [
  [1, 2],
  [3, 4],
]);
```

## Usage

### Initialisation

Signature is `each(...[items|options|concurrency|handler])`.

All arguments are optional and can be defined in any order.

Multiple items (arrays) are merged. Muliple options (objects) are merged as well.

- `items: array`   
  An array containing any type of value. Functions are executed and may return a promise. Promise are waiting to be resolved. Any other type is returned as is or passed as an argument of the `handler` function.
- `option: object`   
  An options object. See below for the list of supported options.
- `concurrency: boolean | integer`   
  A boolean or an integer value. Similar to setting the `concurrency` option property. Jump to the concurrency section below.
- `handler: function`   
  A function which take each item as an argument.

### Options

- `concurrency` (default `1`)   
  An integer value defining the number of functions executed in parallel or a boolean value. Value `false` is converted to `1` where functions are executed sequentially. The value `true` is converted to `-1` where all functions run simultaneously.
- `fluent` (default `true`)
  Expose a fluent API where the functions may be chained.
- `pause` (default `false`)   
  Delay the execution of functions until `resume` is called.
- `relax` (default `false`)   
  Keep scheduling new functions when `call` is further executed.

### Functions

- `call(handler)`   
  Execute one or several items and return a promise with the resolved value(s). Unless the `fluent` option is `false`, it is also possible to chain additional functions.
- `concurrency([level])`   
  Change the number of items executed in parallel.
- `end([error|options])`   
  Close the scheduler and ensure no additionnal items is registered. The returned promise is resolved once all the scheduled items resolve.
- `error(error|null)`   
  Place the scheduler in an error state, all future registered items will be rejected. Use `null` to set the scheduler to a normal state. 
- `options`   
  Return a promise with all options when no argument or with a single option value when one argument. When two arguments are provide as key and value, the promise is resolved when the value is effective.
- `pause`   
  Pause the scheduling of new functions, see the throttling section.
- `resume`   
  Resume the scheduling of new functions, see the throttling section. It returns a promise that resolves once all previously scheduled and paused items are resolved.

## Iteration

### Resolution order

Output order is consistent with input order. The value returned by a function or resolved by a promise is always returned in the same position as it was originally defined.

### Iteration with any type of values

Another type is returned as is unless a handler function is defined.

Each iterates over any type of item. If no handler is defined, functions and and promises get a special treatment. Functions are executed and may return a promise and promises are resolved.

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

Note, in the majority of cases, items (arrays) which do not contain functions and promises are handled with a handler function.

### Iteration over a list of functions

Functions are executed. Each handles both synchronous and asynchronous functions. In the latter case, functions return a Promise and Each wait for their resolution.

Here are various ways to [declare functions](./samples/iteration.functions.js):

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

Each wait for all promises to be resolved before returning their result. Just like with `Promise.all`, [result orders respect registration orders](./samples/iteration.promise.js).

```js
const result = await each([
  // Instant resolution
  new Promise((resolve) => resolve("a")),
  // Delayed resolution
  new Promise((resolve) => setTimeout(() => resolve("b")), 100),
  // Instant resolution
  new Promise((resolve) => resolve("c")),
]);

assert.deepStrictEqual(result, ["a", "b", "c"]);
```

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

Handlers are called with the item as the first argument and the index number as the second argument.

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

Here is an [asynchronous handler](./samples/handler.asynchronous.js) function:

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
  Concurrency is a number. It defines the maximum number of functions running in parallel at a given time.

### Sequential mode (default)

When the `concurrent` option is `undefined`, `false`, or `1`, items are executed [in order one after the other](./samples/mode_concurrent.js).

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

When the `concurrent` mode is a value above `1`, the number of items running simultaneously is [bounded to the `concurrent` value](./samples/mode_concurrent.js).

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

The `pause` option defines the initial status. Its value defaults to `false`.

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

The `resume` and `end` methods return a promise that [resolves once all the element's executions are complete](./samples/throttle.resume.js). This is an example using the `resume` function.

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

Iterations are stopped on error.

With synchronous functions or when the concurrency mode is sequential, it behaves like `Promise.all`. On error, no additionnal function is scheduled for execution and the returned promise is rejected.

With asynchronous functions executed concurrently, no additional functions are scheduled. Already executed functions resolves or rejects their promise but the result is discarded.

Whether the items array is provided at initialization or with the `call` function, the behavior is the same:

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

## API `concurrency`

`concurrency([level])`

- `level` <integer|boolean>   
  New concurrency value

It defines the number of items to be executed in parallel. The new level takes effect for all new scheduled items. Previously scheduled items are unaffected.

Calling the `concurrency` function change the number of items executed in parrallel. Previously scheduled items are not affected. Only the items scheduled after calling the `concurrency` function will honor the new value.

This example [change the `concurrency` level](./samples/api.concurrency.js). The first 3 items are executed in parallel and the next 3 items are executed sequentially.

```js
import assert from "assert";
import each from "each";

const history = [];
const handler = (id) => {
  history.push(`${id}:start`);
  return new Promise((resolve) =>
    setTimeout(() => {
      history.push(`${id}:end`);
      resolve();
    }, 20)
  );
};

const scheduler = each(-1);
// Schedule parallel execution
scheduler.call(() => handler(1));
scheduler.call(() => handler(2));
// Change the concurrency level
scheduler.concurrency(1);
// Schedule sequential execution
scheduler.call(() => handler(4));
scheduler.call(() => handler(5));
// Wait for completion
await scheduler.end();

assert.deepStrictEqual(history, [
  // Parallel execution
  "1:start",
  "2:start",
  "1:end",
  "2:end",
  // Sequential execution
  "4:start",
  "4:end",
  "5:start",
  "5:end",
]);
```

## API `end`

`end([error|options])`

- `error` <Error>   
  Reject the returned promise and every registered item that is not yet executed with an error. All scheduled items not yet executed are resolved with an error. In `relax` mode, only the promise returned by `end` is rejected with an error.
- `force` <boolean>   
  Skip the execution of registered items that are not yet scheduled for execution. The items resolve with undefined or the value associated with the error option.

Close the scheduler. The returned promise waits for all previously scheduled items to resolve.

No further items are allowed to register with `call`. In such case, the returned promise is rejected. When `end` is called and the scheduler is in paused state, all paused items are resolved with `undefined` or an error if any.

This example wait for the completion of two scheduled items before completion.

```js
import assert from "assert";
import each from "each";

const history = [];
const handler = (id) => {
  return new Promise((resolve) =>
    setTimeout(() => {
      history.push(`${id}:end`);
      resolve();
    }, 20)
  );
};

const scheduler = each(-1);
// Schedule parallel execution
scheduler.call(() => handler(1));
scheduler.call(() => handler(2));
// Wait for completion
await scheduler.end();

assert.deepStrictEqual(history, [
  "1:end",
  "2:end",
]);
```

## Option `fluent`

The `fluent` option applies when using the `each().call` function. By default, it is enabled. The API is designed to allow [multiple calls to be chained](./samples/options.fluent.true.js) where the value of the last call is returned:

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

## Option `pause`

The `pause` set the initial mode of the scheduler. It is `false` by default. Setting the scheduler in pause mode implies calling `resume` to start the execution.

## Option `relax`

When the `relax` option is active, the internal scheduler permits the registration of new items with the `call` function even after an error.

It doesn't affect the processing of an `items` list. An error while handling one of the items prevents additionnal execution and rejects the items' promise. However, it provides the ability to register and execute new items with `call`.

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

Tests are executed with [Mocha](https://mochajs.org/). To install the `mocha` package and its dependencies, run `npm install`.

```bash
npm run test
# Or
yarn run test
```

To automatically generate a new version and publish it:

```bash
yarn run release
```

Package publication is handled by the CI/CD with GitHub action.

## History

* Version 2 is a complete rewrite based on promise.
* Version above 0.8.0 renamed then to next.
* Versions above 0.2.x, changed the arguments of the callback.
