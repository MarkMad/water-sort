import 'package:hive/hive.dart';
import 'package:watersort/domain/models/user_profile.dart';

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 1;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return UserProfile(
      id: fields[0]?.toString() ?? 'default_profile',
      name: fields[1]?.toString() ?? 'Player 1',
      createdAt: fields[2] is int
          ? DateTime.fromMillisecondsSinceEpoch(fields[2] as int)
          : (fields[2] is num
              ? DateTime.fromMillisecondsSinceEpoch((fields[2] as num).toInt())
              : DateTime.now()),
      avatarEmoji: fields[3]?.toString() ?? '🧪',
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer.writeByte(4);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.createdAt.millisecondsSinceEpoch);
    writer.writeByte(3);
    writer.write(obj.avatarEmoji);
  }
}
