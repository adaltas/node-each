import assert from "assert";
import each from "../lib/index.js";

const stack = [];
const result = await each(
  [
    () =>
      new Promise((resolve) => {
        setTimeout(() => stack.push("Is") && resolve("Is"), 30);
      }),
    () =>
      new Promise((resolve) => {
        setTimeout(() => stack.push("Gollum") && resolve("Gollum"), 20);
      }),
    () =>
      new Promise((resolve) => {
        setTimeout(() => stack.push("Around") && resolve("Around"), 10);
      }),
  ],
  true,
);

assert.equal(result.join(" "), "Is Gollum Around");
assert.equal(stack.join(" "), "Around Gollum Is");
