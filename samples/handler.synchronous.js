
import each from '../lib/index.js';
import assert from 'assert';

const result = await each(
  [{id: 'a'}, {id: 'b'}, {id: 'c'}, {id: 'd'}],
  (item, index) =>
    `${item.id}@${index}`
);

assert.deepStrictEqual(
  result, 
  ['a@0', 'b@1', 'c@2', 'd@3']
);
