import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s_social/core/domain/model/post_model.dart';
import 'package:s_social/core/domain/repository/post_repository.dart';
import 'package:s_social/core/domain/repository/upload_file_repository.dart';
import 'package:s_social/core/domain/repository/user_repository.dart';
import 'package:s_social/core/utils/extensions/is_current_user.dart';
import 'package:s_social/features/screen/home/logic/post_state.dart';

import '../../../../core/domain/model/user_model.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepository postRepository;
  final UploadFileRepository uploadFileRepository;
  final UserRepository userRepository;

  PostCubit({
    required this.postRepository,
    required this.uploadFileRepository,
    required this.userRepository,
  }) : super(PostInitial());

  Future<void> loadPosts({String? userId}) async {
    try {
      emit(PostLoading());
      final allPosts = await postRepository.getPosts() ?? [];
      final allUsers = await userRepository.getUsersByIds(
          allPosts.map((e) => e.userId.toString()).toSet().toList());

      final posts = await postRepository.getPosts(userId: userId) ?? [];

      final showPosts = posts.map((post) {
        UserModel? foundUser;
        for (UserModel user in allUsers ?? []) {
          if (post.userId == user.id) {
            foundUser = user;
            break;
          }
        }

        if (post.id != null) {
          for (PostModel p in allPosts) {
            if (post.originalPost?.id == p.id) {
              post = post.copyWith(originalPost: p);
            }
          }
        }

        for (UserModel user in allUsers ?? []) {
          if (post.originalUser?.id == user.id) {
            post = post.copyWith(originalUser: user);
          }
        }

        return ShowPost(user: foundUser, post: post);
      }).toList();

      emit(PostLoaded(showPosts));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<PostModel?> createPost(
    String? userId,
    String content,
    File? imageFile,
  ) async {
    try {
      String? imgUrl;

      if (imageFile != null) {
        imgUrl = await uploadImageToFirebase(imageFile);
      }

      final newPost = PostModel(
        id: null,
        userId: userId,
        postContent: content,
        postImage: imgUrl,
        createdAt: DateTime.now(),
        like: 0,
      );
      return await postRepository.createPost(newPost);
    } catch (_) {
      return null;
    }
  }

  Future<PostModel?> sharePost(
    String content,
    String? originalPostId,
    String? originalUserId,
  ) async {
    try {
      final newPost = PostModel(
        id: null,
        userId: currentUid,
        postContent: content,
        postImage: null,
        createdAt: DateTime.now(),
        like: 0,
        originalPost: PostModel(id: originalPostId),
        originalUser: UserModel(id: originalUserId),
      );
      return await postRepository.createPost(newPost);
    } catch (_) {
      return null;
    }
  }

  Future<void> deletePost(PostModel postId) async {
    try {
      await postRepository.deletePost(postId);
      await loadPosts();
    } catch (_) {}
  }

  Future<String?> uploadImageToFirebase(File imageFile) async {
    try {
      final url = uploadFileRepository.postFile(imageFile);
      return url;
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      return await userRepository.getUserById(userId);
    } catch (_) {
      return null;
    }
  }
}
