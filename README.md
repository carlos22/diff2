# diff2

Calculate the difference between two things and apply them to other things

## API

### `diff.calculateDifferences(oldObject, newObject)`

Calculate the differences between the old object and the new object.
The differences will be output as a series of actions.

### `diff.applyDifferences(targetObject, differences)`

Apply calculated differences to an object.
This can also be an empty object to get a tree like representation of the differences.