
import each from '../lib/index.js'
import assert from 'assert'

const result = await each(
  [{id: 'a'}, {id: 'b'}, {id: 'c'}, {id: 'd'}],
  function(item, index){
    return new Promise( (resolve) =>
      setTimeout(() => resolve(`${item.id}@${index}`), 100)
    )
  }
)

assert.deepStrictEqual(
  result, 
  ['a@0', 'b@1', 'c@2', 'd@3']
)
