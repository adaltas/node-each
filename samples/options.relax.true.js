
import each from '../lib/index.js'
import assert from 'assert'

const scheduler = each({relax: true})
const prom1 = scheduler.call(
  () => new Promise( (resolve) => resolve(1) )
)
const prom2 = scheduler.call(
  () => new Promise( (resolve, reject) => reject(2) )
)
const prom3 = scheduler.call(
  () => new Promise( (resolve) => resolve(3) )
)

const result = await Promise.allSettled([prom1, prom2, prom3])
assert.deepStrictEqual(result, [
  {status: 'fulfilled', value: 1},
  {status: 'rejected', reason: 2},
  {status: 'fulfilled', value: 3}
])
