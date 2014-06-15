diff = require './diff'

describe 'diff', ->

  oldObject = null
  newObject = null

  describe 'properties', ->

    beforeEach ->
      oldObject =
        foo: 'bar'
      newObject = diff._clone oldObject


    it 'should track and apply property changes', ->
      newObject.foo = 'moo'
      calculateAndApply oldObject, newObject


    it 'should track and apply property deletions', ->
      delete newObject.foo
      calculateAndApply oldObject, newObject


    it 'should track and apply property creations', ->
      newObject.foo2 = 'bar2'
      calculateAndApply oldObject, newObject


    it 'should track and apply property type changes', ->
      newObject.foo = 1
      calculateAndApply oldObject, newObject


  describe 'objects', ->

    it 'should track and apply empty object creations', ->
      oldObject = {}
      newObject = diff._clone oldObject
      newObject.foo = {}
      calculateAndApply oldObject, newObject


    it 'should track and apply pre filled object creations', ->
      oldObject = {}
      newObject = diff._clone oldObject
      newObject.foo =
        childFoo: 'childBar'
      calculateAndApply oldObject, newObject


    it 'should track and apply object property creations', ->
      oldObject =
        foo: {}
      newObject = diff._clone oldObject
      newObject.foo.bar = 'bar'
      calculateAndApply oldObject, newObject


    it 'should track and apply object property changes', ->
      oldObject =
        foo:
          childFoo: 'childBar'
      newObject = diff._clone oldObject
      newObject.foo.childFoo = 'childBar2'
      calculateAndApply oldObject, newObject


    it 'should track and apply object property deletions', ->
      oldObject =
        foo:
          childFoo: 'childBar'
      newObject = diff._clone oldObject
      delete newObject.foo.childFoo
      calculateAndApply oldObject, newObject


    it 'should track and apply object replacements', ->
      oldObject =
        foo:
          childFoo: 'childBar'
      newObject = diff._clone oldObject
      newObject.foo =
        childFoo2: 'childBar2'
      calculateAndApply oldObject, newObject


    it 'should track and apply object deletions', ->
      oldObject =
        foo:
          childFoo: 'childBar'
      newObject = diff._clone oldObject
      delete newObject.foo
      calculateAndApply oldObject, newObject


  describe 'arrays', ->

    it 'should track and apply empty array creations', ->
      oldObject = {}
      newObject = diff._clone oldObject
      newObject.array = []
      calculateAndApply oldObject, newObject


    it 'should track and apply pre filled array creations', ->
      oldObject = {}
      newObject = diff._clone oldObject
      newObject.array = [1, 2, 3]
      calculateAndApply oldObject, newObject


    it 'should track and apply push of new elements', ->
      oldObject =
        array: []
      newObject = diff._clone oldObject
      newObject.array.push 1
      calculateAndApply oldObject, newObject


    it 'should track and apply removal of elements', ->
      oldObject =
        array: [1]
      newObject = diff._clone oldObject
      newObject.array.pop()
      calculateAndApply oldObject, newObject


    it 'should track and apply value changes of elements', ->
      oldObject =
        array: [1]
      newObject = diff._clone oldObject
      newObject.array[0] = 2
      calculateAndApply oldObject, newObject


    it 'should track and apply property changes of object elements', ->
      oldObject =
        array: [foo: 'bar']
      newObject = diff._clone oldObject
      newObject.array[0].foo = 'baz'
      calculateAndApply oldObject, newObject


    it 'should track and apply array deletions', ->
      oldObject =
        array: []
      newObject = diff._clone oldObject
      delete newObject.array
      calculateAndApply oldObject, newObject


    it 'should track and apply array replacements', ->
      oldObject =
        array: [1, 2, 3]
      newObject = diff._clone oldObject
      newObject.array = [4, 5, 6]
      calculateAndApply oldObject, newObject


    it 'should track and apply movement of objects inside array', ->
      oldObject =
        array: [{foo: 'bar'}, {moo: 'cow'}]
      newObject = diff._clone oldObject
      first = diff._clone oldObject.array[0]
      second = diff._clone oldObject.array[1]
      newObject.array = [first, second]
      calculateAndApply oldObject, newObject


  describe 'advanced', ->
    beforeEach ->
      oldObject =
        someProp: 'bar'
        someObject: {foo: 'bar'}
        someArray: ['foo', 'bar']
        someNested:
          so: [
            'deep'
            'dig'
            {
              deeper: [
                'oh'
                {so: 'deep'}
              ]
            }
            {
              notsodeep: [
                'batman'
              ]
            }
          ]
      newObject = diff._clone oldObject
      newObject.someProp = 'moo'
      newObject.someNested.soNew = 'wat'
      newObject.someNested.someArray = []
      newObject.someNested.someArray[23] = 'yeah'
      newObject.someNested.someArray[42] = 'HAE'
      delete newObject.someNested.so[1]
      newObject.someNested.so[2].deeper[1].so = 'deepest'
      newObject.someNested.so[2].deeper[1].noes = 'gotchya'
      newObject.someNested.so[2].deeper.push 'TROLLFACE'
      deepObj = diff._clone newObject.someNested.so[2]
      notsodeepObj = diff._clone newObject.someNested.so[3]
      newObject.someNested.so[2] = notsodeepObj
      newObject.someNested.so[3] = deepObj


    it 'should track and apply the mixed changes', ->
      calculateAndApply oldObject, newObject


    it 'should be able to supply the differences in tree format', ->
      differences = diff.calculateDifferences oldObject, newObject
      difftree = diff.applyDifferences {}, differences

      diffObject = {}
      diffObject.someProp = 'moo'
      diffObject.someNested = {}
      diffObject.someNested.soNew = 'wat'
      diffObject.someNested.someArray = []
      diffObject.someNested.someArray[23] = 'yeah'
      diffObject.someNested.someArray[42] = 'HAE'
      diffObject.someNested.so = []
      diffObject.someNested.so[2] =
        notsodeep: [
          'batman'
        ]
      diffObject.someNested.so[3] =
        deeper: ['oh']

      diffObject.someNested.so[3].deeper[1] = {}
      diffObject.someNested.so[3].deeper[1].so = 'deepest'
      diffObject.someNested.so[3].deeper[1].noes = 'gotchya'
      diffObject.someNested.so[3].deeper.push 'TROLLFACE'
      expect(diffObject).to.deep.equal difftree


    it 'should not modify the given differences array while applying differences', ->
      oldObject = {}
      newObject = {name: 'John'}
      differences = diff.calculateDifferences oldObject, newObject
      differencesClone = diff._clone differences
      diff.applyDifferences oldObject, differences
      expect(differences).to.deep.equal differencesClone


    it 'should ignore functions', ->
      oldObject = {}
      newObject = {foo: ->}
      differences = diff.calculateDifferences oldObject, newObject
      diff.applyDifferences oldObject, differences
      expect(oldObject).to.deep.equal {}


calculateAndApply = (oldObject, newObject) ->
  differences = diff.calculateDifferences oldObject, newObject
  appliedObj = diff.applyDifferences oldObject, differences
  expect(newObject).to.deep.equal appliedObj
