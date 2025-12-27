// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class PostAdapter extends TypeAdapter<Post> {
  @override
  final typeId = 0;

  @override
  Post read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Post(
      id: fields[0] as String,
      title: fields[1] as String,
      summary: fields[2] as String,
      createdAt: fields[3] as DateTime,
      lastUpdatedAt: fields[4] as DateTime?,
      tags: (fields[5] as List).cast<String>(),
      coverImage: fields[6] as String?,
      content: fields[7] as String?,
      author: fields[8] == null ? 'Admin' : fields[8] as String,
      primaryCategory: fields[9] == null ? 'General' : fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Post obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.summary)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.lastUpdatedAt)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.coverImage)
      ..writeByte(7)
      ..write(obj.content)
      ..writeByte(8)
      ..write(obj.author)
      ..writeByte(9)
      ..write(obj.primaryCategory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
