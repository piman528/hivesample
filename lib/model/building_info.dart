import 'package:hivesample/model/room.dart';

class BuildingInfo {
  BuildingInfo({
    required this.buildingId,
    required this.buildingName,
    required this.rooms,
  });

  // JSON からオブジェクトを生成するファクトリメソッド
  factory BuildingInfo.fromJson(Map<String, dynamic> json) {
    return BuildingInfo(
      buildingId: json['id'] as int,
      buildingName: json['name'] as String,
      rooms: (json['rooms'] as Map<String, dynamic>).map(
        (floor, rooms) => MapEntry(
          floor,
          (rooms as List<dynamic>).map((room) => Room.fromJson(room)).toList(),
        ),
      ),
    );
  }

  final String buildingName;
  final int buildingId;
  final Map<String, List<Room>> rooms;
}
