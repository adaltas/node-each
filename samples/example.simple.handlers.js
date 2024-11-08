import assert from "assert";
import each from "../lib/index.js";

const stack = [];
const result = await each(
  [
    { message: "Is", timeout: 30 },
    { message: "Gollum", timeout: 20 },
    { message: "Around", timeout: 10 },
  ],
  { concurrency: true },
  ({ message, timeout }) =>
    new Promise((resolve) =>
      setTimeout(() => stack.push(message) && resolve(message), timeout),
    ),
);

assert.equal(result.join(" "), "Is Gollum Around");
assert.equal(stack.join(" "), "Around Gollum Is");
