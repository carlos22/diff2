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

Given:

```javascript
oldObject = {
  property: 'value',
  nestedObject: {
    foo: 'bar',
    number: 1
  },
  array: [1, 2, 3, 4, 5]
};

newObject = {
  property: 'new value',
  nestedObject: {
    foo: 'baz'
  },
  newNestedObject: {
    bar: 'foo'
  },
  array: [3, 2, 1, 4]
};
```

Executing `diff.calculateDifferences(oldObject, newObject);` will output:

```javascript
[ { type: 'changed',
    path: [ { key: 'property', valueType: 'string' } ],
    value: 'new value' },
  { type: 'changed',
    path:
     [ { key: 'nestedObject', valueType: 'object' },
       { key: 'foo', valueType: 'string' } ],
    value: 'baz' },
  { type: 'deleted',
    path:
     [ { key: 'nestedObject', valueType: 'object' },
       { key: 'number', valueType: 'undefined' } ],
    value: undefined },
  { type: 'changed',
    path:
     [ { key: 'array', valueType: 'array' },
       { key: '0', valueType: 'number' } ],
    value: 3 },
  { type: 'changed',
    path:
     [ { key: 'array', valueType: 'array' },
       { key: '2', valueType: 'number' } ],
    value: 1 },
  { type: 'deleted',
    path:
     [ { key: 'array', valueType: 'array' },
       { key: '4', valueType: 'undefined' } ],
    value: undefined },
  { type: 'added',
    path: [ { key: 'newNestedObject', valueType: 'object' } ],
    value: { bar: 'foo' } } ]
```

Executing `diff.applyDifferences(oldObject, differences);` will cause oldObject to deep equal newObject.

Executing `diff.applyDifferences(emptyObject, differences);` will result in a tree like representation:

```javascript
{ property: 'new value',
  nestedObject: { foo: 'baz' },
  array: [ 3, , 1 ],
  newNestedObject: { bar: 'foo' } }
```