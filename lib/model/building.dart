import 'package:hivesample/model/room.dart';

class Building {
  final int id;
  final String name;
  final Map<String, List<Room>>? rooms;

  Building({
    required this.id,
    required this.name,
    this.rooms,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Building.fromJson(Map<String, dynamic> json) {
    if (json['rooms'] != null) {
      Map<String, List<Room>> roomsMap = {};
      json['rooms'].forEach((floor, rooms) {
        roomsMap[floor] =
            (rooms as List).map((room) => Room.fromJson(room)).toList();
      });
      return Building(
        id: int.parse(json['id']),
        name: json['name'],
        rooms: roomsMap,
      );
    } else {
      return Building(
        id: int.parse(json['id']),
        name: json['name'],
      );
    }
  }
}
