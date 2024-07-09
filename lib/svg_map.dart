import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SVGMap extends HookConsumerWidget {
  const SVGMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectShape = ref.watch(shapeProvider);
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
          for (final shape in shapes.value) {
            final path = shape.transformedPath;
            final selected =
                path!.contains(details.localPosition) && shape.isSelectable;
            if (selected) {
              ref.read(shapeProvider.notifier).state = buildings[shape.id - 1];
            }
          }
        }
        pointerDownPosition.value = null;
      },
      child: RepaintBoundary(
        child: CustomPaint(
          painter: SVGMapRender(
            selectShape: selectShape?.mapShape,
            shapes: shapes.value,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
