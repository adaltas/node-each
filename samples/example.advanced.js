import assert from "assert";
import each from "each";

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
