import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:s_social/core/domain/repository/user_repository.dart';
import 'package:s_social/core/utils/extensions/is_current_user.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.userRepository}) : super(const AuthState(false));

  final UserRepository userRepository;

  void checkLogin() {
    emit(AuthState(FirebaseAuth.instance.currentUser != null));
  }

  Future<void> login() async {
    emit(const AuthState(true));
    _addFcmToken();
  }

  Future<void> _addFcmToken() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }

    final foundUser = await userRepository.getUserById(uid);
    if (foundUser == null) {
      return;
    }

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) {
      return;
    }

    await userRepository.updateUser(
      foundUser.copyWith(
        fcmTokens: token,
      ),
    );
  }

  Future<void> logout() async {
    emit(const AuthState(false));
    _removeFcmToken();
  }

  Future<void> _removeFcmToken() async {
    final foundUser = await userRepository.getUserById(currentUid);
    if (foundUser == null) {
      return;
    }

    await userRepository.updateUser(
      foundUser.copyWith(
        fcmTokens: "",
      ),
    );

    await FirebaseAuth.instance.signOut();
  }
}
