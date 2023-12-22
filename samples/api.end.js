import assert from "assert";
import each from "each";

const history = [];
const handler = (id) => {
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
// Wait for completion
await scheduler.end();

assert.deepStrictEqual(history, [
  "1:end",
  "2:end",
]);
