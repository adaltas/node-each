import assert from "assert";
import each from "each";

const result = await each([
  // Item is a value
  "a",
  // Item is a function
  () => new Promise((resolve) => resolve("b")),
  // Item is a promise
  new Promise((resolve) => resolve("c")),
]);

assert.deepStrictEqual(result, ["a", "b", "c"]);
