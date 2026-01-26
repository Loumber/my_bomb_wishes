import 'package:flutter/material.dart';
import 'package:my_bomb_wishes/common/app/app.dart';
import 'package:my_bomb_wishes/common/init/app_initializer.dart';

void main() async {
  await AppInitializer.init();
  runApp(const MyApp());
}
