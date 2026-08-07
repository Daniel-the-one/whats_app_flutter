import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whats_app_flutter/provider/user_provider.dart';
import 'package:whats_app_flutter/view/home.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (context) => UserProvider(),child: const MainApp(),));

}

class MainApp extends StatelessWidget {
  const MainApp({super.key});


  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
