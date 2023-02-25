
import each from '../lib/index.js'

describe 'api.call', ->

  describe 'parallel sync', ->

    it 'function', ->
      scheduler = each()
      Promise.all [
          scheduler.call -> new Promise (resolve) -> resolve 1
          scheduler.call -> new Promise (resolve) -> resolve 2
        ]
      .should.be.resolvedWith [1, 2]

    it 'an array', ->
      scheduler = each()
      Promise.all [
          scheduler.call [
            -> new Promise (resolve) -> resolve 1
            -> new Promise (resolve) -> resolve 2
          ]
          scheduler.call [
            -> new Promise (resolve) -> resolve 3
            -> new Promise (resolve) -> resolve 4
          ]
        ]
      .should.be.resolvedWith [[1, 2], [3, 4]]

    it 'an empty array', ->
      scheduler = each()
      Promise.all [
          scheduler.call []
          scheduler.call []
        ]
      .should.be.resolvedWith [[], []]

  describe 'parallel async', ->

    it 'function', ->
      scheduler = each()
      Promise.all [
          scheduler.call -> new Promise (resolve) -> setTimeout (-> resolve 1), 50
          scheduler.call -> new Promise (resolve) -> setTimeout (-> resolve 2), 100
          scheduler.call -> new Promise (resolve) -> setTimeout (-> resolve 3), 50
        ]
      .should.be.resolvedWith [1, 2, 3]

    it 'an array', ->
      scheduler = each()
      Promise.all [
          scheduler.call [
            -> new Promise (resolve) -> setTimeout (-> resolve 1), 50
            -> new Promise (resolve) -> setTimeout (-> resolve 2), 100
            -> new Promise (resolve) -> setTimeout (-> resolve 3), 50
          ]
          scheduler.call [
            -> new Promise (resolve) -> setTimeout (-> resolve 4), 50
            -> new Promise (resolve) -> setTimeout (-> resolve 5), 100
            -> new Promise (resolve) -> setTimeout (-> resolve 6), 50
          ]
        ]
      .should.be.resolvedWith [[1, 2, 3], [4, 5, 6]]
  
  describe 'error', ->
    
    it 'throw error', ->
      scheduler = each()
      scheduler.call -> 'ok'
      scheduler.call -> throw Error 'catchme'
      scheduler.call -> 'ok'
      .should.be.rejectedWith 'catchme'
    
    it 'reject error in same tick', ->
      scheduler = each()
      scheduler.call -> 'ok'
      scheduler.call -> new Promise (resolve, reject) -> reject Error 'catchme'
      scheduler.call -> 'ok'
      .should.be.rejectedWith 'catchme'
    
    it 'reject error in next tick', ->
      scheduler = each()
      scheduler.call -> 'ok'
      scheduler.call -> new Promise (resolve, reject) -> setImmediate -> reject Error 'catchme'
      scheduler.call -> 'ok'
      .should.be.rejectedWith 'catchme'
    

    
  
