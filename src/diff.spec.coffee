diff = require './diff'

describe 'diff', ->

  oldObject = null
  newObject = null

  describe 'given simple properties', ->

    beforeEach ->
      oldObject =
        foo: 'bar'
      newObject = clone oldObject


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


  describe 'given nested objects', ->

    it 'should track and apply empty object creations', ->
      oldObject = {}
      newObject = clone oldObject
      newObject.foo = {}
      calculateAndApply oldObject, newObject


    it 'should track and apply pre filled object creations', ->
      oldObject = {}
      newObject = clone oldObject
      newObject.foo =
        childFoo: 'childBar'
      calculateAndApply oldObject, newObject


    it 'should track and apply object property creations', ->
      oldObject =
        foo: {}
      newObject = clone oldObject
      newObject.foo.bar = 'bar'
      calculateAndApply oldObject, newObject


    it 'should track and apply object property changes', ->
      oldObject =
        foo:
          childFoo: 'childBar'
      newObject = clone oldObject
      newObject.foo.childFoo = 'childBar2'
      calculateAndApply oldObject, newObject


    it 'should track and apply object property deletions', ->
      oldObject =
        foo:
          childFoo: 'childBar'
      newObject = clone oldObject
      delete newObject.foo.childFoo
      calculateAndApply oldObject, newObject


    it 'should track and apply object replacements', ->
      oldObject =
        foo:
          childFoo: 'childBar'
      newObject = clone oldObject
      newObject.foo =
        childFoo2: 'childBar2'
      calculateAndApply oldObject, newObject


    it 'should track and apply object deletions', ->
      oldObject =
        foo:
          childFoo: 'childBar'
      newObject = clone oldObject
      delete newObject.foo
      calculateAndApply oldObject, newObject


  describe 'given nested arrays', ->

    it 'should track and apply empty array creations', ->
      oldObject = {}
      newObject = clone oldObject
      newObject.array = []
      calculateAndApply oldObject, newObject


    it 'should track and apply pre filled array creations', ->
      oldObject = {}
      newObject = clone oldObject
      newObject.array = [1, 2, 3]
      calculateAndApply oldObject, newObject


    it 'should track and apply push of new elements', ->
      oldObject =
        array: []
      newObject = clone oldObject
      newObject.array.push 1
      calculateAndApply oldObject, newObject


    it 'should track and apply removal of elements', ->
      oldObject =
        array: [1]
      newObject = clone oldObject
      newObject.array.pop()
      calculateAndApply oldObject, newObject


    it 'should track and apply value changes of elements', ->
      oldObject =
        array: [1]
      newObject = clone oldObject
      newObject.array[0] = 2
      calculateAndApply oldObject, newObject


    it 'should track and apply property changes of object elements', ->
      oldObject =
        array: [foo: 'bar']
      newObject = clone oldObject
      newObject.array[0].foo = 'baz'
      calculateAndApply oldObject, newObject


    it 'should track and apply array deletions', ->
      oldObject =
        array: []
      newObject = clone oldObject
      delete newObject.array
      calculateAndApply oldObject, newObject


    it 'should track and apply array replacements', ->
      oldObject =
        array: [1, 2, 3]
      newObject = clone oldObject
      newObject.array = [4, 5, 6]
      calculateAndApply oldObject, newObject


    it 'should track and apply movement of objects inside array', ->
      oldObject =
        array: [{foo: 'bar'}, {moo: 'cow'}]
      newObject = clone oldObject
      first = clone oldObject.array[0]
      second = clone oldObject.array[1]
      newObject.array = [first, second]
      calculateAndApply oldObject, newObject


  describe 'given a complex object', ->
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
      newObject = clone oldObject
      newObject.someProp = 'moo'
      newObject.someNested.soNew = 'wat'
      newObject.someNested.someArray = []
      newObject.someNested.someArray[23] = 'yeah'
      newObject.someNested.someArray[42] = 'HAE'
      delete newObject.someNested.so[1]
      newObject.someNested.so[2].deeper[1].so = 'deepest'
      newObject.someNested.so[2].deeper[1].noes = 'gotchya'
      newObject.someNested.so[2].deeper.push 'TROLLFACE'
      deepObj = clone newObject.someNested.so[2]
      notsodeepObj = clone newObject.someNested.so[3]
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

    it 'should not modify the given differences upon applying', ->
      oldObject = {}
      newObject = {name: 'John'}
      differences = diff.calculateDifferences oldObject, newObject
      differencesClone = clone differences
      diff.applyDifferences oldObject, differences
      expect(differences).to.deep.equal differencesClone


    it.only 'should track and apply differences 10000 times', ->
      for i in [0..10000]
        differences = diff.calculateDifferences oldObject, newObject
        diff.applyDifferences oldObject, differences


calculateAndApply = (oldObject, newObject) ->
  differences = diff.calculateDifferences oldObject, newObject
  appliedObj = diff.applyDifferences oldObject, differences
  expect(newObject).to.deep.equal appliedObj


clone = (input) ->
  output = null
  if typeof input is 'object'
    output = diff._createFromType diff._getType input
    Object.keys(input).forEach (key) =>
      output[key] = clone input[key]
  else
    output = input
  output
