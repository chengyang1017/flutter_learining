import 'package:flutter/material.dart';
import '../features/home/screens/home_screen.dart';

class PlaygroundApp extends StatelessWidget {
  const PlaygroundApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter UI Playground',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      );
}
