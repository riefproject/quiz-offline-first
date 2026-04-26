import 'dart:typed_data';

abstract interface class ByteSerializable {
  /// Converts the object into a raw byte array for BLE transmission
  Uint8List toBytes();
}
