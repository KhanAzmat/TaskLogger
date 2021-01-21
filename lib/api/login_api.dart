//import 'dart:js';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:task_logger/api/userSetup.dart';
import 'package:task_logger/model/User1.dart';
import 'package:task_logger/notifier/auth_notifier.dart';
import 'package:task_logger/pages/HomePage.dart';
import 'package:task_logger/pages/adminPage.dart';
import 'package:task_logger/pages/welcomepage.dart';
import 'package:task_logger/api/crud.dart';

String uid = "";
login(User1 user1, AuthNotifier authNotifier, BuildContext context) async {
  var log = Logger();
  log.i(user1.email);
  log.i(user1.password);
  try {
    final User firebaseUser = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: user1.email, password: user1.password))
        .user;
    await FirebaseAuth.instance.currentUser
        .updateProfile(displayName: user1.name);

    authNotifier.setUser(firebaseUser);
    log.i("login: $firebaseUser");
    // user1.name = firebaseUser.displayName;
    // user1.admin = false;
    // addUserData(user1, firebaseUser.uid);
    FirebaseFirestore.instance
        .collection('data')
        .doc(firebaseUser.uid)
        .get()
        .then((value) {
      if (value.data()["admin"] == true) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AdminPage()),
            (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(uid: firebaseUser.uid)),
            (route) => false);
      }
    });
  } catch (error) {
    log.i(error);
  }
}

signUp(User1 user, AuthNotifier authNotifier, BuildContext context) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  var log = Logger();
  try {
    User firebaseUser = (await auth.createUserWithEmailAndPassword(
            email: user.email, password: user.password))
        .user;
    await FirebaseAuth.instance.currentUser
        .updateProfile(displayName: user.name);

    await firebaseUser.reload();

    log.i("Sign Up: $firebaseUser");
    authNotifier.setUser(await FirebaseAuth.instance.currentUser);

    addUserData(user, firebaseUser.uid);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(uid: firebaseUser.uid)),
        (route) => false);
  } catch (error) {
    print(error);
  }
}

signOut(AuthNotifier authNotifier, BuildContext context) async {
  var log = Logger();
  User user = await FirebaseAuth.instance.currentUser;
  //var len = user.providerData.length;
  final googleSignIn = GoogleSignIn();
  try {
    if (user.providerData[user.providerData.length - 1].providerId ==
        'google.com') {
      await googleSignIn.signOut();
    } else {
      await FirebaseAuth.instance.signOut();
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => WelcomePage()));
    authNotifier.setUser(null);
  } catch (error) {
    log.i(error);
  }
}

initializeCurrentUser(AuthNotifier authNotifier) async {
  var log = Logger();
  User firebaseUser = await FirebaseAuth.instance.currentUser;
  log.i(firebaseUser);
  if (firebaseUser != null) {
    authNotifier.setUser(firebaseUser);
  }
}

// userHelper() {
//   CollectionReference collectionReference =
//       FirebaseFirestore.instance.collection('data');
// }
