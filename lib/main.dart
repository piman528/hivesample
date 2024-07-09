import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hivesample/building_list.dart';
import 'package:hivesample/db/db_helper.dart';
import 'package:hivesample/model/building.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();

  if (!(await dbHelper.isTableExists('buildings'))) {
    final jsonData = await rootBundle.loadString('assets/building.json');
    await dbHelper.importFromJson(jsonData);
  }
  final allInfo = await dbHelper.getAllBuildingInfo();
  for (var info in allInfo) {
    print(
        '建物: ${info['buildingName']}, フロア: ${info['floor']}, 部屋: ${info['roomName']}');
  }
  final result = await dbHelper.searchRoom('G');
  for (var info in result) {
    print(
        '建物: ${info['buildingName']}, フロア: ${info['floor']}, 部屋: ${info['roomName']}');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final List<Building> buildings;
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ,
    );
  }
}
