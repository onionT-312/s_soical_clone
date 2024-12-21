import 'package:json_annotation/json_annotation.dart';
import 'package:s_social/core/domain/model/user_model.dart';

part 'post_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PostModel {
  final String? id;

  /// If [userId] null -> Anonymous post
  final String? userId;
  final String? postContent;
  final String? postImage;
  final DateTime? createdAt;
  final int? like;
  final PostModel? originalPost;
  final UserModel? originalUser;

  PostModel({
    this.id,
    this.userId,
    this.postContent,
    this.postImage,
    this.createdAt,
    this.like,
    this.originalPost,
    this.originalUser,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  PostModel copyWith({
    String? id,
    String? userId,
    String? postContent,
    String? postImage,
    DateTime? createdAt,
    int? like,
    PostModel? originalPost,
    UserModel? originalUser,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postContent: postContent ?? this.postContent,
      postImage: postImage ?? this.postImage,
      createdAt: createdAt ?? this.createdAt,
      like: like ?? this.like,
      originalPost: originalPost ?? this.originalPost,
      originalUser: originalUser ?? this.originalUser,
    );
  }
}
