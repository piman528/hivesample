import 'package:collection/collection.dart';
import 'package:hivesample/model/map_shape.dart';

class MapStateData {
  final List<MapShape> shapes;
  final int? selectedShapeId;

  MapStateData({required this.shapes, this.selectedShapeId});

  MapShape? getSelectShape() {
    return shapes.firstWhereOrNull((shape) => shape.id == selectedShapeId);
  }
}
