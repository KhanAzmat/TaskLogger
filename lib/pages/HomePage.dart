import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:task_logger/Screen/todayTask.dart';
import 'package:task_logger/api/crud.dart';
import 'package:task_logger/api/login_api.dart';
import 'package:task_logger/model/task.dart';
import 'package:task_logger/notifier/auth_notifier.dart';
import './pastTask.dart';
import './adminPage.dart';
import 'package:task_logger/pages/welcomepage.dart';

class HomePage extends StatefulWidget {
  final String uid;
  HomePage({Key key, @required this.uid}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState(uid);
}

class _HomePageState extends State<HomePage> {
  DateTime pickedDate;
  DateTime now = DateTime.now();

  final String uid;
  _HomePageState(this.uid);
  var log = Logger();
  String formatDate;
  Task _task = new Task();
  var _globalkey = GlobalKey<FormState>();
  TextEditingController dateController = TextEditingController();
  TextEditingController taskController = TextEditingController();
  User user = FirebaseAuth.instance.currentUser;

  //String date, task;

  @override
  initState() {
    super.initState();
    pickedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    bool admin = false;
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('data');

    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);

    collectionReference.doc(user.uid).get().then((value) {
      if (value.data()["admin"] == true) {
        admin = true;
      } else {
        admin = false;
      }
    });

    return admin == true
        ? AdminPage()
        : Scaffold(
            //drawer
            drawer: Drawer(
                child: ListView(
              children: [
                DrawerHeader(
                  child: Column(
                    children: [
                      CircleAvatar(radius: 50, backgroundColor: Colors.black),
                      SizedBox(height: 10),
                      Text('${user.displayName}'),
                    ],
                  ),
                ),
                ListTile(
                  title: Text('Admin Page'),
                  trailing: Icon(Icons.launch, color: Colors.black),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AdminPage()));
                  },
                ),
                ListTile(
                  title: Text('Logout'),
                  trailing:
                      Icon(Icons.power_settings_new_sharp, color: Colors.black),
                  onTap: () {
                    signOut(authNotifier, context);
                  },
                ),
              ],
            )),

            //appbar
            appBar: AppBar(
                elevation: 0.0,
                flexibleSpace: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(colors: [
                          Color.fromRGBO(143, 148, 251, 1),
                          Color.fromRGBO(1413, 148, 251, 0.6)
                        ]))),
                title: Text("Home Page", style: TextStyle(color: Colors.black)),
                centerTitle: true,
                backgroundColor: Colors.white,
                iconTheme: IconThemeData(color: Colors.black),
                actions: [
                  FlatButton(
                      onPressed: () {
                        signOut(authNotifier, context);
                      },
                      child: Text("Logout",
                          style: TextStyle(fontSize: 20, color: Colors.black)))
                ]),
            //body
            body: Container(
              child: StreamBuilder(
                stream: getUserTaskStreamSnapshot(context),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot ds = snapshot.data.docs[index];

                        return Dismissible(
                          key: Key(ds.id),
                          onDismissed: (right) {
                            // Remove the item from the data source.
                            FirebaseFirestore.instance
                                .collection('data')
                                .doc(uid)
                                .collection('task')
                                .doc(ds.id)
                                .delete();
                            // setState(() {
                            //   snapshot.data.docs.removeAt(index);
                            // });

                            // Then show a snackbar.
                            // Scaffold.of(context).showSnackBar(
                            //     SnackBar(content: Text("$ds dismissed")));
                          },
                          background: Container(color: Colors.red),
                          child: Container(
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
                              onTap: () {},
                            ),
                          ),
                        );

                        // return Container(
                        //   decoration: BoxDecoration(
                        //     color: Colors.purple,
                        //     borderRadius: BorderRadius.circular(5.0),
                        //   ),
                        //   margin: EdgeInsets.all(8.0),
                        //   child: ListTile(
                        //     title: Text(
                        //       ds['task'],
                        //       style: TextStyle(
                        //         fontFamily: "tepeno",
                        //         fontSize: 18.0,
                        //         color: Colors.white,
                        //       ),
                        //     ),
                        //     onLongPress: () {
                        //       // delete
                        //       // collectionReference
                        //       //     .doc(uid)
                        //       //     .collection('task')
                        //       //     .doc(ds.id)
                        //       //     .delete();
                        //     },
                        //     onTap: () {},
                        //   ),
                        // );
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

            floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.teal[300],
                onPressed: () {
                  showAddTaskDialog(context);
                },
                child: Text("+",
                    style: TextStyle(fontSize: 40, color: Colors.black))),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
                elevation: 0.0,
                color: Colors.white,
                shape: CircularNotchedRectangle(),
                notchMargin: 12,
                child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(colors: [
                          Color.fromRGBO(143, 148, 251, 1),
                          Color.fromRGBO(1413, 148, 251, 0.6)
                        ])),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.calendar_today),
                            color: Colors.black,
                            onPressed: () {
                              pickDate();
                            },
                            iconSize: 35,
                          ),
                          IconButton(
                            icon: Icon(Icons.person),
                            color: Colors.black,
                            onPressed: () {},
                            iconSize: 35,
                          ),
                        ],
                      ),
                    ))),
          );
  }

  Stream<QuerySnapshot> getUserTaskStreamSnapshot(BuildContext context) async* {
    final uid = await FirebaseAuth.instance.currentUser.uid;

    String formattedDate = DateFormat('yMd').format(DateTime.now());
    log.i(formattedDate);
    yield* FirebaseFirestore.instance
        .collection('data')
        .doc(uid)
        .collection('task')
        .where('date', isEqualTo: formattedDate)
        .orderBy('time', descending: true)

        //.orderBy('date', descending: true)
        .snapshots();
  }

  pickDate() async {
    DateTime date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2040),
      initialDate: pickedDate,
    );
    if (date != null) {
      String formattedDate = DateFormat('yMd').format(date);
      dateController.text = formattedDate;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PastTask(date: dateController.text)));
    }
  }

  Future<void> showAddTaskDialog(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                  content: Form(
                    key: _globalkey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Add Task",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          dateField(),
                          taskField(),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                        child: Text('Submit'),
                        onPressed: () {
                          setState(() {
                            _task.date = formatDate;
                            _task.time = DateTime.now();
                            _task.task = taskController.text;
                          });
                          log.i(_task);
                          addData(_task, uid);

                          Navigator.of(context).pop();
                        }),
                    TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                  ]),
            ));
  }

  Widget dateField() {
    var now = new DateTime.now();
    formatDate = DateFormat('yMd').format(now);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10.0),
      child: Column(
        children: [
          Text("Date"),
          TextFormField(
            //controller: dateController,
            initialValue: formatDate,
            enabled: false,
            // onSaved: (String value) {
            //   _task.date = value;
            // },
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget taskField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10.0),
      child: Column(
        children: [
          Text("Task"),
          TextFormField(
            controller: taskController,
            initialValue: null,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
