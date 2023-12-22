import assert from "assert";
import each from "each";

let state = 'paused';
const scheduler = each({pause: true});
scheduler.then(() =>
  assert.deepStrictEqual(
    state, 'resumed'
  )
);
setTimeout(() => {
  state = 'resumed';
  scheduler.resume();
}, 100);
