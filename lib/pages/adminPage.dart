import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:task_logger/api/login_api.dart';
import 'package:task_logger/notifier/auth_notifier.dart';
import 'package:task_logger/pages/userTask.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  DateTime pickedDate = DateTime.now();
  TextEditingController dateController = TextEditingController();
  var log = Logger();

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          flexibleSpace: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(colors: [
                    Color.fromRGBO(143, 148, 251, 1),
                    Color.fromRGBO(1413, 148, 251, 0.6)
                  ]))),
          title: Text("Admin Panel"),
          centerTitle: true,
          actions: [
            FlatButton(
                onPressed: () {
                  signOut(authNotifier, context);
                },
                child: Text("Logout",
                    style: TextStyle(fontSize: 20, color: Colors.black)))
          ]),
      body: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('data').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(
                        ds['name'],
                        style: TextStyle(
                          fontFamily: "tepeno",
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                      // onLongPress: () {},
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    UserTask(name: ds['name'], uid: ds.id)));
                      },
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              log.i(snapshot.error);
              return CircularProgressIndicator();
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  // Stream<QuerySnapshot> getUserStreamSnapshot(BuildContext context) async* {
  //   final uid = await FirebaseAuth.instance.currentUser.uid;

  //   String formattedDate = DateFormat('yMd').format(DateTime.now());
  //   log.i(formattedDate);
  //   yield* FirebaseFirestore.instance
  //       .collection('data')
  //       .doc(uid).snapshots();
  // }

  Widget userList() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          child: ListView(children: [
        InkWell(
          onTap: () {
            pickDate();
          },
          child: Card(
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
              child: Row(children: [
                Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.black,
                    )),
                SizedBox(width: 20),
                Text("User A",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
              ]),
            ),
          ),
        ),
      ])),
    );
  }

  pickDate() async {
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2040),
      initialDate: pickedDate,
    );
    if (date != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      dateController.text = formattedDate;
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserTask()));
    }
  }
}
