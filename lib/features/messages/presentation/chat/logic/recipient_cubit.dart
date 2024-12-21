import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s_social/features/messages/presentation/chat/logic/recipient_state.dart';

import '../../../../../core/domain/repository/user_repository.dart';

class RecipientCubit extends Cubit<RecipientState> {
  RecipientCubit({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(RecipientInitial());

  final UserRepository _userRepository;

  Future<void> getUserById(String id) async {
    emit(RecipientLoading());
    try {
      final user =  await _userRepository.getUserById(id);
      emit(RecipientLoaded(user!));
    } catch (e) {
      emit(RecipientError(e.toString()));
    }
  }
}
