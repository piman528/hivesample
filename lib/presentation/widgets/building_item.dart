import 'package:flutter/material.dart';
import 'package:hivesample/building_probvider.dart';
import 'package:hivesample/model/building.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BuildingItem extends ConsumerWidget {
  const BuildingItem({super.key, required this.building});
  final Building building;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            ref.read(shapeProvider.notifier).state = building.id;
          },
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            width: double.infinity,
            child: Text(building.name),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
