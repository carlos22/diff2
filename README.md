# diff2

Calculate the difference between two JavaScript objects and apply them to other JavaScript objects.

## API

### `diff.calculateDifferences(oldObject, newObject)`

Calculate the differences between the old object and the new object.
The differences will be output as a series of actions.

### `diff.applyDifferences(targetObject, differences)`

Apply calculated differences to an object.
This can also be an empty object to get a tree like representation of the differences.

## Example

```javascript
var oldObject = {
  property: 'value'
  nestedObject: {
    foo: 'bar'
    number: 1
  }
  array: [1, 2, 3, 4, 5]
}

var newObject = {
  property: 'new value'
  nestedObject: {
    foo: 'baz'
  }
  newNestedObject: {
    bar: 'foo'
  }
  array: [3, 2, 1, 4]
}

var differences = diff.calculateDifferences(oldObject, newObject);
diff.applyDifferences(oldObject, differences);
// oldObject is now deep equal to newObject

var diffAsTree = {};
diff.applyDifferences(diffAsTree, differences);
// diffAsTree reflects the differences as tree
```