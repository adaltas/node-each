import assert from "assert";
import each from "each";

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
