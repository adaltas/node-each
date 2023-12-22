import assert from "assert";
import each from "each";

const scheduler = each();
const prom1 = scheduler.call(
  () => new Promise((resolve) => resolve(1))
);
const prom2 = scheduler.call(
  () => new Promise((resolve, reject) => reject(2))
);
const prom3 = scheduler.call(
  () => new Promise((resolve) => resolve(3))
);

const result = await Promise.allSettled([prom1, prom2, prom3]);
assert.deepStrictEqual(result, [
  {status: 'fulfilled', value: 1},
  {status: 'rejected', reason: 2},
  {status: 'rejected', reason: 2}
]);
