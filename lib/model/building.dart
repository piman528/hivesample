import 'package:hivesample/model/room.dart';

class Building {
  final String id;
  final String name;
  final Map<String, List<Room>> rooms;

  Building({
    required this.id,
    required this.name,
    required this.rooms,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Building.fromJson(Map<String, dynamic> json) {
    Map<String, List<Room>> roomsMap = {};
    json['rooms'].forEach((floor, rooms) {
      roomsMap[floor] =
          (rooms as List).map((room) => Room.fromJson(room)).toList();
    });

    return Building(
      id: json['id'],
      name: json['name'],
      rooms: roomsMap,
    );
  }
}
