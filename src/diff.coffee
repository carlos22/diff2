class Diff

  @DIFFERENCE_TYPES =
    ADDED: 'added'
    DELETED: 'deleted'
    CHANGED: 'changed'

  calculateDifferences: (oldValue, newValue, key = '', path = []) ->
    newValueType = @_getType newValue
    oldValueType = @_getType oldValue
    if key isnt ''
      pathElement =
        key: key
        valueType: newValueType
      path = [].concat path, [pathElement]
    if typeof oldValue is 'function' or typeof newValue is 'function'
      return []
    else if oldValueType is 'undefined'
      return [@_createDifference Diff.DIFFERENCE_TYPES.ADDED, path, newValue]
    else if newValueType is 'undefined'
      return [@_createDifference Diff.DIFFERENCE_TYPES.DELETED, path]
    else if oldValueType isnt newValueType
      return [@_createDifference Diff.DIFFERENCE_TYPES.CHANGED, path, newValue]
    else if oldValueType is 'object' or oldValueType is 'array'
      return @_getNestedDifferences oldValue, newValue, path
    else if newValue isnt oldValue
      return [@_createDifference Diff.DIFFERENCE_TYPES.CHANGED, path, newValue]
    else
      return []


  _createDifference: (type, path, value) ->
    difference =
      type: type
      path: path
    if @_getType value isnt 'undefined'
      difference.value = value
    difference


  _getNestedDifferences: (oldObject, newObject, path = []) ->
    allKeysToCheck = @_union Object.keys(oldObject), Object.keys(newObject)
    differences = allKeysToCheck.map(
      (key) =>
        @calculateDifferences oldObject[key], newObject[key], key, path
    )
    @_flatten(differences)


  _union: (array1, array2) ->
    array1.concat array2.filter (value) -> array1.indexOf(value) is -1


  _flatten: (arrayOfArrays) ->
    arrayOfArrays.reduce ((prev, current) -> prev.concat current), []


  _getType: (input) ->
    type = typeof input
    if type is 'object' and @_isArray input
      'array'
    else
      type


  _isArray: (input) ->
    {}.toString.call(input) is "[object Array]"


  applyDifferences: (object, differences) ->
    differences.forEach (difference) =>
      pathCopy = difference.path.slice 0
      lastKey = pathCopy.pop().key
      lastReference = pathCopy.reduce(
        (object, pathElement) =>
          if not object[pathElement.key]
            @_createValue object, pathElement.key, pathElement.valueType
          object[pathElement.key]
      , object
      )
      if difference.type is Diff.DIFFERENCE_TYPES.CHANGED or difference.type is Diff.DIFFERENCE_TYPES.ADDED
        lastReference[lastKey] = difference.value
      else
        delete lastReference[lastKey]
    object


  _createValue: (object, key, type) ->
    object[key] = @_createFromType type


  _createFromType: (type) ->
    return {} if type is 'object'
    return [] if type is 'array'


module.exports = new Diff