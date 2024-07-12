import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hivesample/building_probvider.dart';
import 'package:hivesample/model/map_shape.dart';
import 'package:hivesample/infra/svg_loader.dart';
import 'package:hivesample/presentation/widgets/svg_render.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SVGMap extends HookConsumerWidget {
  const SVGMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final selectShape = ref.watch(shapeProvider);
    final pointerDownPosition = useRef<Offset?>(null);

    final shapes = useState<List<MapShape>>([]);
    useEffect(
      () {
        SVGLoader().loadSVGMap().then((loadShapes) {
          shapes.value = loadShapes;
        });
        return null;
      },
      [],
    );
    return GestureDetector(
      onTapDown: (details) {
        pointerDownPosition.value = details.localPosition;
      },
      onTapUp: (details) {
        if (details.localPosition == pointerDownPosition.value) {
          final select = shapes.value.firstWhereOrNull((shape) {
            final path = shape.transformedPath;
            return path!.contains(details.localPosition) && shape.isSelectable;
          });
          ref.read(shapeProvider.notifier).state = select?.id;
        }
        pointerDownPosition.value = null;
      },
      child: RepaintBoundary(
        child: CustomPaint(
          painter: SVGMapRender(
            selectShape: null,
            shapes: shapes.value,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
