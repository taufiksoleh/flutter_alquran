import 'package:alquran/sura/ui/sura_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Al Quran',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColorDark: Colors.black
      ),
      home: SuraScreen(title: 'Surat'),
    );
  }
}