import assert from "assert";
import each from "../lib/index.js";

let state = "paused";
const scheduler = each({ pause: true });
scheduler.then(() => assert.deepStrictEqual(state, "resumed"));
setTimeout(() => {
  state = "resumed";
  scheduler.resume();
}, 100);
