// lib/core/data/adapters/date_time_adapter.dart

import 'package:hive_ce/hive.dart'; // <-- UPDATED IMPORT

/// This adapter teaches Hive how to store the DateTime object.
/// It converts DateTime to an integer (millisecondsSinceEpoch) for storage
/// and converts the integer back to DateTime when reading.
class DateTimeAdapter extends TypeAdapter<DateTime> {
  // A unique ID for this adapter. Choose any number not already used.
  @override
  final int typeId = 100; 

  @override
  DateTime read(BinaryReader reader) {
    final millis = reader.readInt();
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  @override
  void write(BinaryWriter writer, DateTime obj) {
    writer.writeInt(obj.millisecondsSinceEpoch);
  }
}