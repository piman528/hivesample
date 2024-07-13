import 'package:hivesample/model/building.dart';
import 'package:hivesample/model/building_room.dart';

class BuildingRoomList {
  BuildingRoomList({
    required this.buildings,
    required this.rooms,
  });
  final List<Building> buildings;
  final List<BuildingRoom> rooms;
}
