import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_logger/model/task.dart';
import 'package:task_logger/model/User1.dart';
//Map<String, String> data;

addData(Task _task, String uid) {
  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('data');
  collectionReference
      .doc(uid)
      .collection('task')
      .add({"date": _task.date, "time": _task.time, "task": _task.task});
}

addUserData(User1 user, String uid) {
  final collectionReference = FirebaseFirestore.instance.collection('data');
  collectionReference.doc(uid).set({"name": user.name, "admin": user.admin});
}

// delete() {
//   CollectionReference collectionReference =
//       FirebaseFirestore.instance.collection('data');
//   collectionReference.doc(uid).collection('task').doc(ds.documentID).delete();
// }
