import assert from "assert";
import each from "each";

const stack = [];
const scheduler = each({ pause: true });
scheduler.call(
  () =>
    new Promise((resolve) => {
      stack.push(1);
      resolve();
    }),
);
scheduler.call(
  () =>
    new Promise((resolve) => {
      stack.push(2);
      resolve();
    }),
);
setTimeout(async () => {
  // Before resume, not processing occurs
  assert.deepStrictEqual(stack, []);
  // Resume and wait for execution
  await scheduler.resume();
  // After resume, every element was processed
  assert.deepStrictEqual(stack, [1, 2]);
}, 100);
