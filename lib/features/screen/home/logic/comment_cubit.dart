import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s_social/core/domain/model/comment_model.dart';
import 'package:s_social/core/domain/repository/comment_repository.dart';
import 'package:s_social/core/domain/repository/upload_file_repository.dart';
import 'package:s_social/features/screen/home/logic/comment_state.dart';
import '../../../../core/domain/model/user_model.dart';

class CommentCubit extends Cubit<CommentState> {
  final CommentRepository commentRepository;
  final UploadFileRepository uploadFileRepository;
  final Map<String, UserModel> userCache = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _hasPreview = false;
  bool get hasPreview => _hasPreview;

  CommentCubit({
    required this.commentRepository,
    required this.uploadFileRepository,
  }) : super(CommentInitial());

  // Future<void> loadComments(String postId) async {
  //   try {
  //     final postRef = _firestore.collection('posts').doc(postId);
  //     final commentsSnapshot = await postRef.collection('comments').get();
  //
  //     if (commentsSnapshot.docs.isEmpty) {
  //       emit([]);
  //     } else {
  //       final comments = commentsSnapshot.docs
  //           .map((doc) => CommentModel.fromJson(doc.data()))
  //           .toList();
  //       emit(comments);
  //     }
  //   } catch (e) {
  //     print("Error loading comments: $e");
  //     emit([]);
  //   }
  // }
  // Sử dụng Stream để nhận bình luận theo thời gian thực
  Stream<List<CommentModel>> loadComments(String postId) {
    final postRef = _firestore.collection('posts').doc(postId);

    return postRef.collection('comments')
        .orderBy('createdAt')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) => CommentModel.fromJson(doc.data())).toList();
    });
  }

  Future<void> addComment(CommentModel comment) async {
    emit(CommentLoading());
    try {
      await commentRepository.addComment(comment);
    } catch (e) {
      emit(CommentError("Failed to add comment: $e"));
    }
  }

  Future<void> deleteComment(String commentId, String postId) async {
    emit(CommentLoading());
    try {
      await commentRepository.deleteComment(commentId as CommentModel);
    } catch (e) {
      emit(CommentError("Failed to delete comment: $e"));
    }
  }

  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      final url = uploadFileRepository.postFile(imageFile);
      return url;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel> getUserById(String userId) async {
    if (userCache.containsKey(userId)) {
      return userCache[userId]!;
    } else {
      final user = await fetchUserData(userId);
      userCache[userId] = user;
      return user;
    }
  }

  Future<UserModel> fetchUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return UserModel(
          id: userId,
          username: userDoc['username'],
          avatarUrl: userDoc['avatarUrl'],
        );
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print("Error fetching user data: $e");
      throw Exception('Failed to fetch user data');
    }
  }

  void updatePreviewStatus(bool status) {
    _hasPreview = status;
    emit(_hasPreview ? ImageUploading() : CommentLoaded([]));
  }
}
