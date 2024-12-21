// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      postContent: json['postContent'] as String?,
      postImage: json['postImage'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      like: (json['like'] as num?)?.toInt(),
      originalPost: json['originalPost'] == null
          ? null
          : PostModel.fromJson(json['originalPost'] as Map<String, dynamic>),
      originalUser: json['originalUser'] == null
          ? null
          : UserModel.fromJson(json['originalUser'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'postContent': instance.postContent,
      'postImage': instance.postImage,
      'createdAt': instance.createdAt?.toIso8601String(),
      'like': instance.like,
      'originalPost': instance.originalPost?.toJson(),
      'originalUser': instance.originalUser?.toJson(),
    };
