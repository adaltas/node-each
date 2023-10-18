
import each from '../lib/index.js';
import assert from 'assert';

const promise = each({ fluent: false })
  .call(
    () => new Promise((resolve) => resolve(1))
  );

assert.strictEqual(promise.call, undefined);
assert.strictEqual(promise.options, undefined);
