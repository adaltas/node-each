
import each from '../src/index.coffee'

describe 'api.items', ->

  describe 'push parallel sync', ->

    it 'function', ->
      scheduler = each()
      Promise.all [
          scheduler.push -> new Promise (resolve) -> resolve 1
          scheduler.push -> new Promise (resolve) -> resolve 2
        ]
      .should.be.resolvedWith [1, 2]

    it 'an array', ->
      scheduler = each()
      Promise.all [
          scheduler.push [
            -> new Promise (resolve) -> resolve 1
            -> new Promise (resolve) -> resolve 2
          ]
          scheduler.push [
            -> new Promise (resolve) -> resolve 3
            -> new Promise (resolve) -> resolve 4
          ]
        ]
      .should.be.resolvedWith [[1, 2], [3, 4]]

    it 'an empty array', ->
      scheduler = each()
      Promise.all [
          scheduler.push []
          scheduler.push []
        ]
      .should.be.resolvedWith [[], []]

  describe 'push parallel async', ->

    it 'function', ->
      scheduler = each()
      Promise.all [
          scheduler.push -> new Promise (resolve) -> setTimeout (-> resolve 1), 50
          scheduler.push -> new Promise (resolve) -> setTimeout (-> resolve 2), 100
          scheduler.push -> new Promise (resolve) -> setTimeout (-> resolve 3), 50
        ]
      .should.be.resolvedWith [1, 2, 3]

    it 'an array', ->
      scheduler = each()
      Promise.all [
          scheduler.push [
            -> new Promise (resolve) -> setTimeout (-> resolve 1), 50
            -> new Promise (resolve) -> setTimeout (-> resolve 2), 100
            -> new Promise (resolve) -> setTimeout (-> resolve 3), 50
          ]
          scheduler.push [
            -> new Promise (resolve) -> setTimeout (-> resolve 4), 50
            -> new Promise (resolve) -> setTimeout (-> resolve 5), 100
            -> new Promise (resolve) -> setTimeout (-> resolve 6), 50
          ]
        ]
      .should.be.resolvedWith [[1, 2, 3], [4, 5, 6]]
    

    
  
