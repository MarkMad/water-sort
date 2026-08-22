import 'package:hive/hive.dart';

import 'package:watersort/domain/models/user_progress.dart';

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 0;

  @override
  UserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    int parseFieldInt(dynamic value, int defaultValue) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    final currentLevel = parseFieldInt(fields[0], 1);
    final highestLevel = parseFieldInt(fields[1], 0);

    int totalMoves = 0;
    if (fields[2] is int || fields[2] is num) {
      totalMoves = parseFieldInt(fields[2], 0);
    } else if (fields[3] is int || fields[3] is num) {
      totalMoves = parseFieldInt(fields[3], 0);
    }

    return UserProgress(
      currentLevel: currentLevel,
      highestLevelCompleted: highestLevel,
      totalMoves: totalMoves,
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer.writeByte(3);
    writer.writeByte(0);
    writer.write(obj.currentLevel);
    writer.writeByte(1);
    writer.write(obj.highestLevelCompleted);
    writer.writeByte(2);
    writer.write(obj.totalMoves);
  }
}
