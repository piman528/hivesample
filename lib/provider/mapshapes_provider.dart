import 'package:hivesample/infra/svg_loader.dart';
import 'package:hivesample/model/map_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mapshapes_provider.g.dart';

@Riverpod(keepAlive: true)
class MapShapesNotifier extends _$MapShapesNotifier {
  @override
  MapStateData build() {
    _load();
    return MapStateData(shapes: [], selectedShapeId: null);
  }

  void _load() async {
    final shapes = await SVGLoader().loadSVGMap();
    state =
        MapStateData(shapes: shapes, selectedShapeId: state.selectedShapeId);
  }

  void selectShape(int? id) {
    if (id != null) {
      state = MapStateData(shapes: state.shapes, selectedShapeId: id);
    } else {
      state = MapStateData(shapes: state.shapes, selectedShapeId: null);
    }
  }
}
