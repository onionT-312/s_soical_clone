import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:s_social/common/app_constants/firestore_collection_constants.dart';

class UserListDataSource {
  final firestoreDatabase = FirebaseFirestore.instance;
  
  CollectionReference get _userListCollection {
    return firestoreDatabase.collection(FirestoreCollectionConstants.userList);
  }

  Stream<DocumentSnapshot<Object?>> listenToUserChatMap(String userId) {
    return _userListCollection.doc(userId).snapshots();
  }
}