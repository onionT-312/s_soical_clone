import 'package:equatable/equatable.dart';

import '../../../../../core/domain/model/user_model.dart';

sealed class RecipientState extends Equatable {
  const RecipientState();

  @override
  List<Object?> get props => [];
}

final class RecipientInitial extends RecipientState {}

final class RecipientLoading extends RecipientState {}

final class RecipientLoaded extends RecipientState {
  const RecipientLoaded(this.user);

  final UserModel user;

  @override
  List<Object?> get props => [user];
}

final class RecipientError extends RecipientState {
  const RecipientError(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
