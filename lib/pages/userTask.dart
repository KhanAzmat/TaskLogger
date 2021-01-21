import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserTask extends StatefulWidget {
  final String name, uid;
  UserTask({Key key, this.name, this.uid}) : super(key: key);
  @override
  _UserTaskState createState() => _UserTaskState(name, uid);
}

class _UserTaskState extends State<UserTask> {
  String name, uid;
  _UserTaskState(this.name, this.uid);
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
          title: Text("$name's tasks"),
          centerTitle: true,
        ),
        // body:
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
                        alignment: Alignment.topLeft,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        margin: EdgeInsets.all(8.0),
                        // child: ListTile(
                        //   title: Text(
                        //     ds['task'],
                        //     style: TextStyle(
                        //       fontFamily: "tepeno",
                        //       fontSize: 18.0,
                        //       color: Colors.white,
                        //     ),
                        //   ),
                        //   onLongPress: () {},
                        //   onTap: () {},
                        // ),

                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ds['task'],
                                  style: TextStyle(
                                    fontFamily: "tepeno",
                                    fontSize: 25.0,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Row(children: [
                                  Text("Created date : ${ds['date']}",
                                      style: TextStyle(
                                        fontFamily: "tepeno",
                                        fontSize: 18.0,
                                        color: Colors.white70,
                                      ))
                                ])
                                // Text(
                                //   ds['time'].toDate().toString(),
                                //   style: TextStyle(
                                //     fontFamily: "tepeno",
                                //     fontSize: 18.0,
                                //     color: Colors.white,
                                //   ),
                                // ),
                              ]),
                        ));
                  },
                );
              } else if (snapshot.hasError) {
                return CircularProgressIndicator();
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ));
  }

  Stream<QuerySnapshot> getUserTaskStreamSnapshot(BuildContext context) async* {
    yield* FirebaseFirestore.instance
        .collection('data')
        .doc(uid)
        .collection('task')
        .orderBy('time', descending: true)
        .snapshots();
  }
}
