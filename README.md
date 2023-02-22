
[![Build Status]([![Build Status](https://github.com/adaltas/node-each/actions/workflows/test.yml/badge.svg))

Each is a single elegant function to iterate over elements  both in `sequential`, `parallel` and `concurrent` mode. It is a powerful and mature library.

Main functionalities include:

* User-defined concurrency level
* Iteration over a list of promise
* Iteration over a list of functions
* Iteration with any items handled by a user-defined function
* Full promise support
* Full test coverage
* Zero dependency

## Usage

Use your favorite package manager to install the `each` package:

```bash
npm install each
```

In ESM:

```js
import each from 'each'
```

Notes:

* Version 2 is a complete rewrite based on promise.
* Version above 0.8.0 renamed then to next.
* Versions above 0.2.x, changed arguments of the item callback.

## Initialisation

Signature is `each(...[items|options|concurrency|handler])`.

All arguments are optional and can be defined in any order.

Multiple items arrays are merged. Muliple options are merged as well.

- `items`   
  An array containing any type of value. Functions are executed and may return a promise. Promise are waiting to be resolved. Any other type is returned as is or pass as an argument of the `handler` function.
- `option`   
  An options object. See below for the list of supported options.
- `concurrency`   
  A boolean or an integer value. Similar to setting the `concurrency` option property. Jump to the concurrency section below.
- `handler`   
  A function which take each item as an argument.

## Options

- `concurrency` (default `1`)   
  An integer value defining the number of function executed in parallel or a boolean value. Value `false` is converted to `1` where functions are executed sequentially. Value `true` is converted to `-1` where all functions run simultaneously.
- `pause` (default `false`)   
  Delay the execution of functions until `resume` is called.
- `relax` (default `false`)   
  Keep scheduling new functions when `call` is further executed.

## API

- `call`   
  Execute one or several items.
- `get`   
  Get all options with no argument, get a single option with one argument, and set the value of an option with two arguments.
- `pause`   
  Pause the scheduling of new functions, see the throttling section.
- `resume`   
  Resume the scheduling of new functions, see the throttling section.

## Iteration

Each iterates over any type of elements

```js
const result = await each([
  () => {},
  () => (new Promise((resolve) => resolve())),
  new Promise((resolve) => resolve()),
  '',
  1,
  // ...
])
```

Function are executed. Each handle both synchronuous and asynchronuous function. In the latter case, function returns a promise and each wait for its resolution.

Promise are waiting to be resolved. Thus, it behaves similar to `Promise.all` if the concurrency level is set to sequential (default).

An other type is returned as is unless an handler function is defined.

## Resolution order

Output order is consistent with input order. The value returned by a function or resolved by a promise is always returned in the same position as it was originally defined.

## Synchronous and asynchronous functions

A function can be an item element or the `handler` option. In both cases, it behaves the same.

It is called with the item as first argument and the index number as the second argument.

Synchronous functions return a value. Asynchronous functions return a Promise.

Here is a [synchronous handler](./samples/handler.synchronous.js) function:

```javascript
const result = await each(
  [{id: 'a'}, {id: 'b'}, {id: 'c'}, {id: 'd'}],
  (item, index) =>
    `${item.id}@${index}`
)

assert.deepStrictEqual(
  result, 
  ['a@0', 'b@1', 'c@2', 'd@3']
)
```

Here is a [asynchronous handler](./samples/handler.asynchronous.js) function:

```javascript
const result = await each(
  [{id: 'a'}, {id: 'b'}, {id: 'c'}, {id: 'd'}],
  (item, index) =>
    new Promise( (resolve) =>
      setTimeout(resolve(`${item.id}@${index}`), 100)
    )
)

assert.deepStrictEqual(
  result, 
  ['a@0', 'b@1', 'c@2', 'd@3']
)
```

## Concurrency modes

- `sequential`   
  Concurrency is `false` or `1`. It is the default concurrency mode.
- `parallel`   
  Concurrency is `true` or `-1`. In asynchronous mode, all the items are executed in parallel.
- `concurrent`   
  Concurrency is a number. It defines the maximum number of function running in parallel at a given time.

## Manual throttling

Use `pause` and `resume` functions to throttle the iteration.

On pause, executed functions pursue their execution and no further function is
scheduled for execution.

Using the `pause` option behaves like calling `pause` right after the initialization. Thus, `each({pause: true})` is an equivalent of `each().pause()`.

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

## Using the `relax` option

When the `relax` option is active, the internal scheduler permit the registration of new items with `call` even after an error.

It doesn't affect the processing of an item list. An error when handling one of the item will prevent additionnal item execution and reject its promise. What it does is to provide the ability to register and execute new items with `call`.

This is an example with the default behavior:

```js
const scheduler = each()
const prom1 = scheduler.call( () => new Promise( (resolve) => resolve(1) ) )
const prom2 = scheduler.call( () => new Promise( (resolve, reject) => reject(2) ) )
const prom3 = scheduler.call( () => new Promise( (resolve) => resolve(3) ) )

const result = await Promise.allSettled([prom1, prom2, prom3])
assert.deepStrictEqual(result, [
  {status: 'fulfilled', value: 1},
  {status: 'rejected', reason: 2},
  {status: 'rejected', reason: 2}
])
```

This is an example with the `relax` option in action:

```js
const scheduler = each({relax: true})
const prom1 = scheduler.call(
  () => new Promise( (resolve) => resolve(1) )
)
const prom2 = scheduler.call(
  () => new Promise( (resolve, reject) => reject(2) )
)
const prom3 = scheduler.call(
  () => new Promise( (resolve) => resolve(3) )
)

const result = await Promise.allSettled([prom1, prom2, prom3])
assert.deepStrictEqual(result, [
  {status: 'fulfilled', value: 1},
  {status: 'rejected', reason: 2},
  {status: 'fulfilled', value: 3}
])
```

## Developers

Tests are executed with [Mocha](https://mochajs.org/). To install it, simple run `npm install`, it will install the `mocha` package and its dependencies.

```bash
npm run test
```

To automatically generate a new version:

```
yarn run release
git push --follow-tags origin master
```

Package publication is handled by the CI/CD with GitHub action.

Note:
- On release, both the publish and test workflows run in parallel. Not very happy about it but I haven't found a better way.
- `yarn` does not call the "postrelease" script and `npm` fails if the `package-lock.json` file is present and git ignored.
