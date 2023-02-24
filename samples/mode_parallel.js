
import each from '../lib/index.js';
import assert from 'assert';

let running = 0;
const result = await each(
  [{id: 'a'}, {id: 'b'}, {id: 'c'}, {id: 'd'}],
  true,
  function(item, index) {
    if(running !== index){ throw Error('Invalid execution'); }
    running++;
    return new Promise((resolve) =>
      setTimeout(() => {
        if(running !== 4-index){ throw Error('Invalid execution'); }
        running--;
        resolve(`${item.id}@${index}`);
      }, 100)
    );
  }
);

assert.deepStrictEqual(
  result, 
  ['a@0', 'b@1', 'c@2', 'd@3']
);
