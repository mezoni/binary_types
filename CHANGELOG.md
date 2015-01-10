## 0.0.6

- Made adaptations to the new version of package `binary_declarations`

## 0.0.5

- Added field `BinaryData.base`
- Added field `BinaryData.offset`  
- Initial support of `binary declartions`. Declarations through the special header files from now supports the `typedef` types, `struct` and `union` declarations
- Removed class `Reference` in favor of the "all-sufficient" implementation of the `Binary Data` 
- Removed getter `BinaryData.location`
- Removed operator `BinaryData.operator~)`

## 0.0.4

- Added `BinaryTypes.declare()`
- Added `BinaryTypes.typeDef()`
- Removed `BinaryTypeHelper.typeDef()`

## 0.0.3

- Changes in the `PointerType.name`. Array types quoted for the better readability. Eg. `(char[10])*` means a pointer to `char[10]`. 

## 0.0.2

- Make available the source code

## 0.0.1

- Initial release

