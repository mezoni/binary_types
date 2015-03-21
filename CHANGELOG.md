## 0.0.33

- Fixed minor bug in the `Type.formatName()` for function pointer

## 0.0.32

- Added initial support for `sizeof()`. From now result of `sizeof()` are an expression
- Added initial support of expresssion in array dimensions and in the enumerators
- Added support for obtaining the declared enumerators through the `BinaryTypeHelper.enumerators`
- Breaking changes. Class `FunctionType` was changed because class `VaListType` was removed
- Breaking changes. Removed class `VaListType` and their kind `BinaryKinds.VA_LIST`
- Made adaptations to the new version of package `binary_declarations`

## 0.0.30

- Added check on `null pointer` in `BinaryTypeHelper.readString()` 
- Added getter `BinaryData.isNullPtr`
- Added getter `BinaryType.nullPtr`
- Deprecated `BinaryType.nullObject()`

## 0.0.29

- Fixed minor bug in the `scope` resolution of the elaborated types

## 0.0.27

- Made adaptations to the new version of package `binary_declarations`

## 0.0.25

- Added support for obtaining the symbol tables during the parsing declarations in `BinaryTypeHelper.declare()`. Into the corresponding symbol tables will be added functions and variables

## 0.0.23

- Completely reimplemented class `_Declarations`
- Initial support of the `_Bool` binary type
- Made adaptations to the new version of package `binary_declarations`    
- Reimplemented the `structural` and the `enumeration` classes to the full support of the declaring type synonyms in the `typedef` declarations

## 0.0.22

- Made adaptations to the new version of package `binary_declarations`

## 0.0.21

- Added possibility to import previously declared types into the new binary types. This allows reuse already the declared binary types
- Breaking changes. Class `BinaryTypes` was freed from the the members that represent primitive types. From now the class `BinaryTypes` is a lightweight class without any public members 

## 0.0.20

- Function `BinaryTypeHelper.declare()` returns now the `Declarations`. This should prevent an unnecessary double parsing of the declarations in `binary_interop` 

## 0.0.19

- Significant rework of the implementation of the performing the type declarations. The support of the attributes `aligned` and `packed` was implemented and was tested
- The predefined values available now in the declarations environment. Currently this is `__OS__` `__BITNESS__`

## 0.0.18

- Made adaptations to the new version of package `binary_declarations`

## 0.0.17

- Class `BinaryTypes` was freed from the all public members (except the members that represent primitive types). From now it ready for use as the base container class for descendant binary types with the members that represent the declared types as members by their names (synonyms)
- Function `BinaryTypes.declare()` was moved to `BinaryTypeHelper.declare()`
- Implementation support of the attributes `aligned` and `packed` almost completed
- Initial support of `attributes`

## 0.0.16

- Added more compatibility with C99 standard. Flexible arrays, declaration and behavior of the bit-fields, behavior of the packed structural types
- Completely reimplemented the structural types. Introduced the concept of the `storage units` for compatibility of the `libffi` library   
- Initial support of `bit-fields`. Currently only declaration without an access/modification (will be added later)
- Slightly reduced the dependence on `unsafe_extension` through the new concept of the `_PhysicalData`. `_PhysicalData` implements `ByteData` with unlimited length (for preventing the overhead on the data manipulation with a large data massives with the length greater than the size of `Smi`)

## 0.0.15

- Added support for macro processing

## 0.0.14

- Better error messages in `BinaryTypes.declare()` about problems in binary declarations 

## 0.0.12

- Added field `BinaryType.original`
- Added field `BinaryTypes.types`

## 0.0.11

- Initial support of `enum` binary type

## 0.0.10

- Added experimental support of `enum` binary type
- Added new concept: type members. Concept actual for `enum`, `struct` and `union` types
- Breaking change: Members of `StructureType` (`struct` and `enum`) now are `StructureMember` instead to be of just a `BinaryTypes`. They holds the information about `name`, `type` and `offset`

## 0.0.9

- Breaking change: `FunctionType` now requires parameter `name`
- Fixed bugs in forming names of the binary types

## 0.0.8

- Completely reimplemented the compatibility type checking mechanics. Now it faster and more accurate and compromise between C and C++ languages
- Completely reimplemented the integer type system fully compatible with the basic C language types

## 0.0.7

- Completely reimplemented the mechanics of naming of the binary types. Now types displayed correctly

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

