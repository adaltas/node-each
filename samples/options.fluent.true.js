import assert from "assert";
import each from "../lib/index.js";

const result = await each()
  .call(() => new Promise((resolve) => resolve(1)))
  .call(() => new Promise((resolve) => resolve(2)))
  .call(() => new Promise((resolve) => resolve(3)));

assert.strictEqual(result, 3);
