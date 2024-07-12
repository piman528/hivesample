import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hivesample/building_probvider.dart';
import 'package:hivesample/infra/db/db_helper.dart';
import 'package:hivesample/model/building.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BuildingInfoSheet extends HookConsumerWidget {
  const BuildingInfoSheet({super.key, required this.controller});
  final DraggableScrollableController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textEditingController = useTextEditingController();
    final selectBuildingint = ref.watch(shapeProvider);
    final typeWord = useState('');
    final db = DatabaseHelper();
    final selectBuilding = useState<Building?>(null);

    useEffect(() {
      if (selectBuildingint != null) {
        db.getBuildingById(selectBuildingint).then((building) {
          selectBuilding.value = building;
          print(building?.name);
        });
      } else {
        selectBuilding.value = null;
      }
      return null;
    }, [selectBuildingint]);

    useEffect(
      () {
        textEditingController.addListener(() {
          typeWord.value = textEditingController.text;
        });
        return null;
      },
      [],
    );

    late final List<Widget> content;

    if (selectBuilding.value != null) {
      content = [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            selectBuilding.value!.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 32),
        if (selectBuilding.value!.rooms != null) ...{
          for (final floor in selectBuilding.value!.rooms!.keys) ...{
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    floor,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GridView.count(
                      padding: const EdgeInsets.all(8),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      children: [
                        for (final classroom
                            in selectBuilding.value!.rooms![floor]!)
                          Container(
                            height: 50,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              classroom.roomName,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          },
        },
      ];
    } else {
      content = [
        const SizedBox(height: 12),
        // SearchBarWidget and other content when no building is selected
      ];
    }

    return DraggableScrollableSheet(
      controller: controller,
      minChildSize: 0.15,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Stack(
            children: [
              ListView(
                physics: const ClampingScrollPhysics(),
                controller: scrollController,
                children: content,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).hintColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
