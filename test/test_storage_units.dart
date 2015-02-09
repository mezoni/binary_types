import "package:binary_types/binary_types.dart";
import "package:unittest/unittest.dart";

void main() {
  for (var isStruct in <bool>[true, false]) {
    group("Storage units in ${isStruct ? "struct" : "union"}.", () {
      test("Only leading zero-length bit-fields.", () {
        var t = new BinaryTypes();
        var members = <StructureMember>[];
        members.add(new StructureMember(null, t["char"], width: 0));
        members.add(new StructureMember(null, t["int"], width: 0));
        var structureType = _createStructureType(isStruct, null, null, t["int"].dataModel);
        var units = new StorageUnits(members, structureType, packed: false);
        var elements = units.elements;
        var unitMembers = units.members;
        expect(elements.length, 0, reason: "Not removed leading zero-length bit-fields");
        expect(unitMembers.length, 0, reason: "Not removed leading zero-length bit-fields");
      });

      test("Leading zero-length bit-fields before other members.", () {
        var t = new BinaryTypes();
        var members = <StructureMember>[];
        members.add(new StructureMember(null, t["char"], width: 0));
        members.add(new StructureMember(null, t["int"], width: 0));
        members.add(new StructureMember("a", t["int"], width: 1));
        var structureType = _createStructureType(isStruct, null, null, t["int"].dataModel);
        var units = new StorageUnits(members, structureType, packed: false);
        var elements = units.elements;
        var unitMembers = units.members;
        expect(elements.length, 1, reason: "Not removed leading zero-length bit-fields");
        expect(unitMembers.length, 1, reason: "Not removed leading zero-length bit-fields");
      });

      test("Leading zero-length bit-fields after other members.", () {
        var t = new BinaryTypes();
        var members = <StructureMember>[];
        members.add(new StructureMember(null, t["char"], width: 0));
        members.add(new StructureMember(null, t["int"], width: 0));
        members.add(new StructureMember("a", t["int"], width: 1));
        members.add(new StructureMember(null, t["char"], width: 0));
        members.add(new StructureMember(null, t["int"], width: 0));
        var structureType = _createStructureType(isStruct, null, null, t["int"].dataModel);
        var units = new StorageUnits(members, structureType, packed: false);
        var elements = units.elements;
        var unitMembers = units.members;
        expect(elements.length, 1, reason: "Not removed leading zero-length bit-fields");
        expect(unitMembers.length, 1, reason: "Not removed leading zero-length bit-fields");
      });

      test("Finishing bit-fields by a zero-length bit-fields.", () {
        var t = new BinaryTypes();
        var members = <StructureMember>[];
        members.add(new StructureMember("a", t["int"], width: 1));
        members.add(new StructureMember(null, t["char"], width: 0));
        members.add(new StructureMember(null, t["long long"], width: 0));
        members.add(new StructureMember(null, t["int"], width: 0));
        var structureType = _createStructureType(isStruct, null, null, t["int"].dataModel);
        var units = new StorageUnits(members, structureType, packed: false);
        var elements = units.elements;
        var unitMembers = units.members;
        var size = elements.first.size;
        expect(size, t["long long"].size, reason: "Chosen not a largest in size finished zero-length bit-field");
      });

      test("Bit-fields in packed units (1 byte).", () {
        var t = new BinaryTypes();
        var members = <StructureMember>[];
        members.add(new StructureMember(null, t["char"], width: 0));
        members.add(new StructureMember(null, t["int"], width: 0));
        members.add(new StructureMember("c", t["char"], width: 1));
        members.add(new StructureMember("i", t["int"], width: 1));
        members.add(new StructureMember("ll", t["long long"], width: 1));
        members.add(new StructureMember(null, t["char"], width: 0));
        members.add(new StructureMember(null, t["int"], width: 0));
        var structureType = _createStructureType(isStruct, null, null, t["int"].dataModel);
        var units = new StorageUnits(members, structureType, packed: true);
        var elements = units.elements;
        var unitMembers = units.members;
        expect(elements.length, 1, reason: "Bit-fields not fits into '1' unit");
        expect(elements.first.size, 1, reason: "Not packed into '1' byte");
        expect(unitMembers.length, 3, reason: "Wrong number of members");
      });

      test("Bit-fields in packed units (3 byte).", () {
        var t = new BinaryTypes();
        var members = <StructureMember>[];
        members.add(new StructureMember(null, t["char"], width: 0));
        members.add(new StructureMember(null, t["int"], width: 0));
        members.add(new StructureMember("c", t["char"], width: 4));
        members.add(new StructureMember("i", t["int"], width: 12));
        members.add(new StructureMember("ll", t["long long"], width: 8));
        members.add(new StructureMember(null, t["char"], width: 0));
        members.add(new StructureMember(null, t["int"], width: 0));
        var structureType = _createStructureType(isStruct, null, null, t["int"].dataModel);
        var units = new StorageUnits(members, structureType, packed: true);
        var elements = units.elements;
        var unitMembers = units.members;
        expect(elements.length, 3, reason: "Bit-fields not fits into '3' unit");
        expect(unitMembers.length, 3, reason: "Wrong number of members");
      });

      test("Bit-fields exceed size in non-packed units.", () {
        var t = new BinaryTypes();
        var members = <StructureMember>[];
        members.add(new StructureMember(null, t["char"], width: 0));
        members.add(new StructureMember(null, t["int"], width: 0));
        members.add(new StructureMember("c0", t["char"], width: 7));
        members.add(new StructureMember("c1", t["char"], width: 2));
        members.add(new StructureMember(null, t["char"], width: 0));
        members.add(new StructureMember(null, t["int"], width: 0));
        var structureType = _createStructureType(isStruct, null, null, t["int"].dataModel);
        var units = new StorageUnits(members, structureType, packed: false);
        var elements = units.elements;
        var unitMembers = units.members;
        expect(elements.length, 2, reason: "Bit-fields not fits into '2' unit");
        expect(unitMembers.length, 2, reason: "Wrong number of members");
      });

      test("Flexible array.", () {
        var t = new BinaryTypes();
        var members = <StructureMember>[];
        members.add(new StructureMember(null, t["long long"], width: 0));
        members.add(new StructureMember("a", t["int"], width: 1));
        members.add(new StructureMember(null, t["long long"], width: 0));
        members.add(new StructureMember("ia", t["int"].array(0)));
        var structureType = _createStructureType(isStruct, null, null, t["int"].dataModel);
        var units = new StorageUnits(members, structureType, packed: false);
        var elements = units.elements;
        var unitMembers = units.members;
        expect(elements.length, 1, reason: "Length of units is not a '1' element");
        expect(unitMembers.length, 2, reason: "Wrong number of members");
      });

      test("Array.", () {
        var t = new BinaryTypes();
        var members = <StructureMember>[];
        members.add(new StructureMember("ia", t["int"].array(2)));
        members.add(new StructureMember(null, t["long long"], width: 0));
        var structureType = _createStructureType(isStruct, null, null, t["int"].dataModel);
        var units = new StorageUnits(members, structureType, packed: false);
        var elements = units.elements;
        var unitMembers = units.members;
        expect(elements.length, 2, reason: "Length of units is not a '2' elements");
        expect(elements.first.type, t["int"], reason: "Type of #1 unit is not an array element type");
        expect(elements.last.type, t["int"], reason: "Type of #2 unit is not an array element type");
        expect(elements.first.align, t["int"].align, reason: "Align of #1 unit not an align of element type");
        expect(elements.last.align, 1, reason: "Align of #2 unit is not '1'");
        expect(unitMembers.length, 1, reason: "Wrong number of members");
        expect(unitMembers["ia"].type, t["int"].array(2), reason: "Member type is not an array type");
      });

      test("Packed struct.", () {
        var t = new BinaryTypes();
        var members = <StructureMember>[];
        members.add(new StructureMember("c", t["char"]));
        members.add(new StructureMember("i", t["int"]));
        members.add(new StructureMember("ll", t["long long"]));
        members.add(new StructureMember(null, t["long long"], width: 0));
        var structureType = _createStructureType(isStruct, null, null, t["int"].dataModel);
        var units = new StorageUnits(members, structureType, packed: true);
        var elements = units.elements;
        var unitMembers = units.members;
        var offsetChar = 0;
        var offsetInt = 0;
        var offsetLongLong = 0;
        if (isStruct) {
          offsetInt = t["char"].size;
          offsetLongLong = offsetInt + t["int"].size;
        }

        expect(elements.length, 3, reason: "Length of units is not a '2' elements");
        expect(unitMembers.length, 3, reason: "Wrong number of members");
        expect(unitMembers["c"].offset, offsetChar, reason: "Wrong offset of 'char' member");
        expect(unitMembers["i"].offset, offsetInt, reason: "Wrong offset of 'int' member");
        expect(unitMembers["ll"].offset, offsetLongLong, reason: "Wrong offset of 'long long' member");
      });

      test("Non packed struct.", () {
        var t = new BinaryTypes();
        var members = <StructureMember>[];
        members.add(new StructureMember("c", t["char"]));
        members.add(new StructureMember("i", t["int"]));
        members.add(new StructureMember("ll", t["long long"]));
        members.add(new StructureMember(null, t["long long"], width: 0));
        var structureType = _createStructureType(isStruct, null, null, t["int"].dataModel);
        var units = new StorageUnits(members, structureType, packed: false);
        var elements = units.elements;
        var unitMembers = units.members;
        var offsetChar = 0;
        var offsetInt = 0;
        var offsetLongLong = 0;
        if (isStruct) {
          offsetInt = t["int"].align;
          offsetLongLong = t["long long"].align;
        }

        expect(elements.length, 3, reason: "Length of units is not a '2' elements");
        expect(unitMembers.length, 3, reason: "Wrong number of members");
        expect(unitMembers["c"].offset, offsetChar, reason: "Wrong offset of 'char' member");
        expect(unitMembers["i"].offset, offsetInt, reason: "Wrong offset of 'int' member");
        expect(unitMembers["ll"].offset, offsetLongLong, reason: "Wrong offset of 'long long' member");
      });
    });
  }
}

StructureType _createStructureType(bool isStruct, String tag, List<StructureMember> members, DataModel dataModel) {
  if (isStruct) {
    return new StructType(tag, members, dataModel);
  } else {
    return new UnionType(tag, members, dataModel);
  }
}
