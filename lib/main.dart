import 'package:flutter/material.dart';
import '../../screens/connexion/login_screen.dart';

void main() {
runApp(const SpeedNetConnectApp());
}

class SpeedNetConnectApp extends StatelessWidget {
const SpeedNetConnectApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'SpeedNetConnect',
debugShowCheckedModeBanner: false,
theme: ThemeData(
colorScheme: ColorScheme.fromSeed(
seedColor: const Color(0xFF1565C0),
),
useMaterial3: true,
fontFamily: 'Roboto',
),
home: const ConnexionScreen(),
);
}
}
