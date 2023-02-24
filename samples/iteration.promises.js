
import each from '../lib/index.js';
import assert from 'assert';

const result = await each([
  // A promise
  new Promise((resolve) => resolve('a')),
  // A promise which resolves after some delay
  () => (
    new Promise((resolve) => setTimeout (() => resolve('b')), 100)
  ),
]);

assert.deepStrictEqual(
  result, 
  ['a', 'b']
);
