import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Animation/FadeAnimation.dart';
import 'notifier/auth_notifier.dart';
import 'pages/HomePage.dart';
import 'pages/welcomepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => AuthNotifier(),
    )
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthNotifier>(builder: (context, notifier, child) {
          return notifier.user != null
              ? HomePage(uid: notifier.user.uid)
              : WelcomePage();
        }));
  }
}
