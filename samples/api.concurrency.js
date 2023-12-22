import assert from "assert";
import each from "each";

const history = [];
const handler = (id) => {
  history.push(`${id}:start`);
  return new Promise((resolve) =>
    setTimeout(() => {
      history.push(`${id}:end`);
      resolve();
    }, 20)
  );
};

const scheduler = each(-1);
// Schedule parallel execution
scheduler.call(() => handler(1));
scheduler.call(() => handler(2));
// Change the concurrency level
scheduler.concurrency(1);
// Schedule sequential execution
scheduler.call(() => handler(4));
scheduler.call(() => handler(5));
// Wait for completion
await scheduler.end();

assert.deepStrictEqual(history, [
  // Parallel execution
  "1:start",
  "2:start",
  "1:end",
  "2:end",
  // Sequential execution
  "4:start",
  "4:end",
  "5:start",
  "5:end",
]);
