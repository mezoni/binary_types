import 'package:binary_types/binary_types.dart';

void main() {
  testSpeed();
}

void testSpeed() {
  var t = new BinaryTypes();
  var sw = new Stopwatch();
  var size = 1000000;
  // int ia[1000000] = {0};
  final ia = t['int'].array(size).alloc([]);
  // int* ip = &ia;
  final ip = t['int*'].alloc(ia);
  final i1 = t['int'].alloc();
  var list1 = new List(size);
  var ia_val;

  var n = 1;
  int temp;
  for (var c = 0; c < n; c++) {
    sw.reset();
    sw.start();
    for (int i = 0; i < size; i++) {
      temp = list1[i];
    }
    sw.stop();
    print('Dart: List[$size] filling in ${sw.elapsedMilliseconds} ms');
  }

  for (var c = 0; c < n; c++) {
    sw.reset();
    sw.start();
    ia_val = ia.value;
    sw.stop();
    print('Binary: ${ia.type} reading into ${ia_val.runtimeType} in ${sw.elapsedMilliseconds} ms');
  }

  for (var c = 0; c < n; c++) {
    sw.reset();
    sw.start();
    ia.value = ia_val;
    sw.stop();
    print('Binary: ${ia.type} writing from ${ia_val.runtimeType} in ${sw.elapsedMilliseconds} ms');
  }

  for (var c = 0; c < n; c++) {
    sw.reset();
    sw.start();
    for (int i = 0; i < size; i++) {
      temp = ia_val[i];
    }
    sw.stop();
    print('Dart: ${ia_val.runtimeType} reading $size times in ${sw.elapsedMilliseconds} ms');
  }

  for (var c = 0; c < n; c++) {
    sw.reset();
    sw.start();
    for (int i = 0; i < size; i++) {
      temp = ia[i].value;
    }
    sw.stop();
    print('Binary: ${ia.type} reading $size times in ${sw.elapsedMilliseconds} ms');
  }

  for (var c = 0; c < n; c++) {
    sw.reset();
    sw.start();
    for (int i = 0; i < size; i++) {
      ia[i].value = i;
    }
    sw.stop();
    print('Binary: ${ia.type} writing $size times in ${sw.elapsedMilliseconds} ms');
  }

  for (var c = 0; c < n; c++) {
    sw.reset();
    sw.start();
    for (int i = 0; i < size; i++) {
      temp = ia.getElementValue(i);
    }
    sw.stop();
    print('Binary: ${ia.type} (fast) reading $size times in ${sw.elapsedMilliseconds} ms');
  }

  for (var c = 0; c < n; c++) {
    sw.reset();
    sw.start();
    for (int i = 0; i < size; i++) {
      ia.setElementValue(i, i);
    }
    sw.stop();
    print('Binary: ${ia.type} (fast) writing $size times in ${sw.elapsedMilliseconds} ms');
  }

  for (var c = 0; c < n; c++) {
    sw.reset();
    sw.start();
    for (int i = 0; i < size; i++) {
      temp = ip[i].value;
    }
    sw.stop();
    print('Binary: ${ip.type} reading $size times in ${sw.elapsedMilliseconds} ms');
  }

  for (var c = 0; c < n; c++) {
    sw.reset();
    sw.start();
    for (int i = 0; i < size; i++) {
      ip[i].value = i;
    }
    sw.stop();
    print('Binary: ${ip.type} writing $size times in ${sw.elapsedMilliseconds} ms');
  }

  for (var c = 0; c < n; c++) {
    sw.reset();
    sw.start();
    for (int i = 0; i < size; i++) {
      temp = ip.getElementValue(i);
    }
    sw.stop();
    print('Binary: ${ip.type} (fast) reading $size times in ${sw.elapsedMilliseconds} ms');
  }

  for (var c = 0; c < n; c++) {
    sw.reset();
    sw.start();
    for (int i = 0; i < size; i++) {
      ip.setElementValue(i, i);
    }
    sw.stop();
    print('Binary: ${ip.type} (fast) writing $size times in ${sw.elapsedMilliseconds} ms');
  }

  for (var c = 0; c < n; c++) {
    sw.reset();
    sw.start();
    for (int i = 0; i < size; i++) {
      temp = i1.value;
    }
    sw.stop();
    print('Binary: ${i1.type} reading $size times in ${sw.elapsedMilliseconds} ms');
  }

  for (var c = 0; c < n; c++) {
    sw.reset();
    sw.start();
    for (int i = 0; i < size; i++) {
      i1.value = i;
    }
    sw.stop();
    print('Binary: ${i1.type} writing $size times in ${sw.elapsedMilliseconds} ms');
  }

  // Prevent to earlier freeing by the garbage collector
  ia.keepAlive();
  i1.keepAlive();
  print("Done.");
}
