import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UserListRepository {
  Stream<DocumentSnapshot<Object?>> listenToUserChatMap(String userId);
}