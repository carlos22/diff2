class Diff

  calculateDifferences: (oldValue, newValue, key = '', path = []) ->
    newValueType = @_getType newValue
    oldValueType = @_getType oldValue
    if key isnt ''
      pathElement =
        key: key
        valueType: newValueType
      path = path.concat [pathElement]
    if not oldValue
      return [@_createDifference 'added', path, newValue]
    else if not newValue
      return [@_createDifference 'delete', path]
    else if oldValueType isnt newValueType
      return [@_createDifference 'change', path, newValue]
    else if typeof oldValue is 'object'
      return @_getNestedDifferences oldValue, newValue, key, path
    else if newValue isnt oldValue
      return [@_createDifference 'change', path, newValue]
    else
      return []


  _createDifference: (type, path, value) ->
    type: type
    path: path
    value: value


  _getNestedDifferences: (oldObject, newObject, key = '', path = []) ->
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
      lastKey = difference.path.pop().key
      lastReference = difference.path.reduce(
        (object, pathElement) =>
          if not object[pathElement.key]
            @_createValue object, pathElement.key, pathElement.valueType
          object[pathElement.key]
      , object
      )
      if difference.type is 'change' or difference.type is 'added'
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