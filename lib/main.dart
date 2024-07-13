import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hivesample/presentation/pages/campus_map.dart';
import 'package:hivesample/infra/db/db_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final jsonData = await rootBundle.loadString('assets/building.json');
  await DatabaseHelper().importFromJson(jsonData);

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
