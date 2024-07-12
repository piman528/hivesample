import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hivesample/presentation/pages/campus_map.dart';
import 'package:hivesample/infra/db/db_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();

  // if (!(await dbHelper.isTableExists('buildings'))) {
  //   final jsonData = await rootBundle.loadString('assets/building.json');
  //   print('a');
  //   await dbHelper.importFromJson(jsonData);
  //   print('1');
  // }
  final jsonData = await rootBundle.loadString('assets/building.json');
  await dbHelper.importFromJson(jsonData);
  // final allInfo = await dbHelper.getAllBuildingInfo();
  // for (var info in allInfo) {
  //   print(
  //       '建物: ${info['buildingName']}, フロア: ${info['floor']}, 部屋: ${info['roomName']}');
  // }
  // final result = await dbHelper.searchRoom('G');
  // for (var info in result) {
  //   print(
  //       '建物: ${info['buildingName']}, フロア: ${info['floor']}, 部屋: ${info['roomName']}');
  // }
  final result1 = await dbHelper.searchBuilding('');
  for (var info in result1) {
    print('建物: ${info['buildingName']}');
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CampusMap(),
    );
  }
}
