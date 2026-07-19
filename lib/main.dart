import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsty_app/routes/index.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFC00003),
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFC00003),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(myApp());
}
