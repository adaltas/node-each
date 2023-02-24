
import each from '../lib/index.js';
import assert from 'assert';

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
