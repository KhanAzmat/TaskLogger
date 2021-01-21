import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class PastTask extends StatelessWidget {
  final String date;
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('data');
  final uid = FirebaseAuth.instance.currentUser.uid;
  var log = Logger();

  PastTask({Key key, this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        title: Text("Task for $date"),
        centerTitle: true,
      ),
      body: Container(
        child: StreamBuilder(
          stream: getUserTaskStreamSnapshot(context),
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
                        ds['task'],
                        style: TextStyle(
                          fontFamily: "tepeno",
                          fontSize: 18.0,
                          color: Colors.white,
                        ),
                      ),
                      onLongPress: () {
                        // delete
                        collectionReference
                            .doc(uid)
                            .collection('task')
                            .doc(ds.id)
                            .delete();
                      },
                      onTap: () {},
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

  Stream<QuerySnapshot> getUserTaskStreamSnapshot(BuildContext context) async* {
    log.i(date);
    yield* FirebaseFirestore.instance
        .collection('data')
        .doc(uid)
        .collection('task')
        .where('date', isEqualTo: date)
        .orderBy('time', descending: true)

        //.orderBy('date', descending: true)
        .snapshots();
  }
}
