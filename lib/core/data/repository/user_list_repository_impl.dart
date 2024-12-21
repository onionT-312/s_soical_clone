import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repository/user_list_repository.dart';
import '../data_source/user_list_data_source.dart';

class UserListRepositoryImpl implements UserListRepository {
  UserListRepositoryImpl({required UserListDataSource userListDataSource})
      : _userListDataSource = userListDataSource;

  final UserListDataSource _userListDataSource;

  @override
  Stream<DocumentSnapshot<Object?>> listenToUserChatMap(String userId) {
    try {
      return _userListDataSource.listenToUserChatMap(userId);
    } catch (_) {
      throw Exception();
    }
  }
}