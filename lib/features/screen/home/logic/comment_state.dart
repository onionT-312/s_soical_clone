import 'package:s_social/core/domain/model/comment_model.dart';

// Define CommentState
abstract class CommentState {}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentLoaded extends CommentState {
  final List<CommentModel> comments;
  CommentLoaded(this.comments);
}

class CommentError extends CommentState {
  final String message;
  CommentError(this.message);
}

class ImageUploading extends CommentState {}

class ImageUploaded extends CommentState {
  final String imageUrl;
  ImageUploaded(this.imageUrl);
}