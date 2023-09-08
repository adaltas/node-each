
import each from '../lib/index.js';
import assert from 'assert';

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
