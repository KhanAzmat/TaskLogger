import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:task_logger/api/crud.dart';

class TodayTask extends StatefulWidget {
  @override
  _TodayTaskState createState() => _TodayTaskState();
}

class _TodayTaskState extends State<TodayTask> {
  var log = Logger();
  Map<String, String> data;

  @override
  Widget build(BuildContext context) {
    fetchData();
    log.i(data.toString());
    return Scaffold();
  }

  fetchData() {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('data');
    collectionReference.snapshots().listen((snapshot) {
      setState(() {
        data = snapshot.docs[0].data();
      });
    });
  }
}
