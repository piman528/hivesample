import 'package:hivesample/infra/db/db_helper.dart';
import 'package:hivesample/model/building.dart';
import 'package:hivesample/model/building_room.dart';
import 'package:hivesample/model/building_room_list.dart';

class SearchBuildingUsecase {
  final db = DatabaseHelper();
  Future<List<BuildingRoom>> searchRooms(String searchWord) async {
    final buildingList = await db.searchRoom(searchWord);
    return buildingList
        .map(
          (building) => BuildingRoom(
            id: int.parse(building['id']),
            roomName: building['roomName'],
            buildingName: building['buildingName'],
            floor: building['floor'],
            roomId: int.parse(
              building['roomId'],
            ),
          ),
        )
        .toList();
  }

  Future<List<Building>> searchBuildings(String searchWord) async {
    final buildingList = await db.searchBuilding(searchWord);
    return buildingList.map((building) {
      return Building(
        id: int.parse(building['id']),
        name: building['buildingName'],
      );
    }).toList();
  }

  Future<BuildingRoomList> searchBuildingRoom(String searchWord) async {
    final roomList = await searchRooms(searchWord);
    final buildingList = await searchBuildings(searchWord);

    return BuildingRoomList(buildings: buildingList, rooms: roomList);
  }
}
