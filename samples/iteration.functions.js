import assert from "assert";
import each from "each";

const result = await each([
  // A synchronous function
  function () {
    return "a";
  },
  // A synchronous function with the fat arrow syntax
  () => "b",
  // An asynchronous function
  () => new Promise((resolve) => resolve("c")),
  // An asynchronous function which resolves after some delay
  () => new Promise((resolve) => setTimeout(() => resolve("d")), 100),
]);

assert.deepStrictEqual(result, ["a", "b", "c", "d"]);
