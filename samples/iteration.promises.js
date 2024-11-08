import assert from "assert";
import each from "../lib/index.js";

const result = await each([
  // Instant resolution
  new Promise((resolve) => resolve("a")),
  // Delayed resolution
  new Promise((resolve) => setTimeout(() => resolve("b")), 100),
  // Instant resolution
  new Promise((resolve) => resolve("c")),
]);

assert.deepStrictEqual(result, ["a", "b", "c"]);
