
import 'package:citations/screens/intro_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/citation_provider.dart';
import 'screens/home_screen.dart';
import 'screens/intro_page.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CitationProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Citation App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: IntroPage(),
      ),
    );
  }
}