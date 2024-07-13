import 'package:flutter/material.dart';
import 'package:hivesample/model/building_room.dart';
import 'package:hivesample/provider/mapshapes_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RoomItem extends ConsumerWidget {
  const RoomItem({super.key, required this.room});
  final BuildingRoom room;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            ref.read(mapShapesNotifierProvider.notifier).selectShape(room.id);
          },
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            width: double.infinity,
            child:
                Text('${room.buildingName} > ${room.floor} > ${room.roomName}'),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
