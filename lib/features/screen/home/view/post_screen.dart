import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:s_social/core/domain/model/comment_model.dart';
import 'package:s_social/core/domain/model/post_model.dart';
import 'package:s_social/core/domain/model/user_model.dart';
import 'package:s_social/core/presentation/logic/cubit/profile_user/profile_user_cubit.dart';
import 'package:s_social/core/utils/ui/dialog_loading.dart';
import 'package:s_social/di/injection_container.dart';
import 'package:s_social/features/screen/home/logic/post_cubit.dart';
import 'package:s_social/features/screen/home/view/widget/comment_widget.dart';
import 'package:s_social/features/screen/home/view/widget/full_screen_img.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/domain/model/reaction_model.dart';
import '../../../../core/utils/ui/cache_image.dart';
import '../../../../generated/l10n.dart';
import '../logic/comment_cubit.dart';
import '../logic/reaction_cubit.dart';

class PostScreen extends StatelessWidget {
  const PostScreen({
    super.key,
    required this.postData,
    required this.postUserData,
  });

  final PostModel postData;
  final UserModel? postUserData;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CommentCubit(
              commentRepository: serviceLocator(),
              uploadFileRepository: serviceLocator()),
        ),
        BlocProvider(
          create: (context) => PostCubit(
            postRepository: serviceLocator(),
            uploadFileRepository: serviceLocator(),
            userRepository: serviceLocator(),
          ),
        ),
      ],
      child: _PostScreen(
        postData: postData,
        postUserData: postUserData,
      ),
    );
  }
}

class _PostScreen extends StatefulWidget {
  final PostModel postData;
  final UserModel? postUserData;

  const _PostScreen({
    required this.postData,
    required this.postUserData,
  });

  @override
  State<StatefulWidget> createState() => _PostScreenState();
}

class _PostScreenState extends State<_PostScreen> {
  bool isReact = false;
  int reactCount = 0;

  @override
  void initState() {
    super.initState();
    context.read<CommentCubit>().loadComments(widget.postData.id!);
    _fetchReactStatus();
    _fetchReactCount();
  }

  void _fetchReactStatus() async {
    final reactionCubit = context.read<ReactionCubit>();
    bool reacted = await reactionCubit.checkUserReacted(
      widget.postData.id!,
      'posts',
      'like',
    );
    if (mounted) {
      setState(() {
        isReact = reacted;
      });
    }
  }

  void _fetchReactCount() async {
    final reactionCubit = context.read<ReactionCubit>();
    reactionCubit
        .countReactions(
      widget.postData.id!,
      'posts',
    )
        .listen((count) {
      if (mounted) {
        setState(() {
          reactCount = count;
        });
      }
    });
  }

  void _toggleReact() {
    final reactionCubit = context.read<ReactionCubit>();
    final userSnapshot = context.read<ProfileUserCubit>();

    reactionCubit.toggleReaction(
      ReactionModel(
        userId: userSnapshot.currentUser?.id,
        targetId: widget.postData.id,
        targetType: 'posts',
        reactionType: 'like',
        isReaction: !isReact,
        updateTime: DateTime.now(),
      ),
    );

    setState(() {
      isReact = !isReact;
    });
  }

  @override
  Widget build(BuildContext context) {
    String? userPostName = widget.postData.userId == null
        ? S.of(context).anonymous
        : widget.postUserData?.username;
    final inputFieldHeight = context.watch<CommentCubit>().hasPreview ? 175.0 : 75.0;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenHeight = constraints.maxHeight;
          final double appBarHeight = kToolbarHeight;
          // final double inputFieldHeight = 60.0;
          final double contentHeight =
              screenHeight - appBarHeight - inputFieldHeight;

          return Column(
            children: [
              AppBar(
                title: Text('Bài viết của $userPostName'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: contentHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PostSection(
                          postData: widget.postData,
                          userData: widget.postUserData,
                          reactCount: reactCount,
                          isReact: isReact,
                          toggleReact: _toggleReact,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            S.of(context).comment,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        StreamBuilder<List<CommentModel>>(
                          stream: context
                              .read<CommentCubit>()
                              .loadComments(widget.postData.id!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return const Center(
                                  child: Text('Error fetching comments.'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(S.of(context).no_comment_yet),
                                ),
                              );
                            }
                            List<CommentModel> comments = snapshot.data!;

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                return FutureBuilder<UserModel>(
                                  future: context
                                      .read<CommentCubit>()
                                      .getUserById(comment.userId!),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return const Center(
                                          child: Text('Error fetching user.'));
                                    } else if (!snapshot.hasData) {
                                      return const Center(
                                          child: Text('User not found.'));
                                    }

                                    final userComment = snapshot.data!;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: CommentWidget(
                                        commentData: comment,
                                        postData: widget.postData,
                                        userData: userComment,
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: SizedBox(
                  height: inputFieldHeight,
                  child: _CommentInputField(
                    postId: widget.postData.id!,
                    userId: FirebaseAuth.instance.currentUser?.uid ?? "",
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PostSection extends StatelessWidget {
  final PostModel postData;
  final UserModel? userData;
  final bool isReact;
  final int reactCount;
  final VoidCallback toggleReact;

  const _PostSection({
    required this.postData,
    required this.userData,
    required this.reactCount,
    required this.isReact,
    required this.toggleReact,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0.5),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.zero)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(postData.postContent ?? ""),
          ),
          if (postData.postImage != null && postData.postImage!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FullScreenImg(imageUrl: postData.postImage!),
                    ),
                  );
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return CacheImage(
                      imageUrl: postData.postImage ?? "",
                      loadingWidth: constraints.maxWidth,
                      loadingHeight: constraints.maxWidth * 0.6,
                    );
                  },
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isReact ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        color: isReact
                            ? Colors.blue
                            : Theme.of(context).colorScheme.onPrimaryFixed,
                      ),
                      onPressed: toggleReact,
                    ),
                    Text(
                      '$reactCount ${S.of(context).like}',
                      style: const TextStyle(
                        fontSize: 15,
                        // color: isReact ? Colors.blue : Theme.of(context).colorScheme.onPrimaryFixed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentInputField extends StatefulWidget {
  final String postId;
  final String userId;

  const _CommentInputField({
    required this.postId,
    required this.userId,
  });

  @override
  _CommentInputFieldState createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<_CommentInputField> {
  final TextEditingController _contentController = TextEditingController();
  File? _selectedImg;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile =
    await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImg = File(pickedFile.path);
        context.read<CommentCubit>().updatePreviewStatus(true);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? pickedFile =
    await _imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImg = File(pickedFile.path);
        context.read<CommentCubit>().updatePreviewStatus(true);
      });
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImg = null;
      context.read<CommentCubit>().updatePreviewStatus(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Column(
        children: [
          if (_selectedImg != null)
            Stack(
              children: [
                Container(
                  constraints: const BoxConstraints(maxHeight: 95),
                  margin: const EdgeInsets.only(bottom: 5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.file(
                      _selectedImg!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: _clearImage,
                    child: CircleAvatar(
                      backgroundColor: Colors.grey.withOpacity(0.7),
                      radius: 10,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.photo_library_outlined),
                onPressed: _pickImageFromGallery,
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined),
                onPressed: _takePhoto,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: S.of(context).write_comment,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  if (_contentController.text.isNotEmpty || _selectedImg != null) {
                    String? imgUrl;
                    if (_selectedImg != null) {
                      imgUrl = await context.read<CommentCubit>().uploadImageToFirebase(_selectedImg!);
                    }

                    // Tạo đối tượng CommentModel
                    final postRef =
                    FirebaseFirestore.instance.collection('posts').doc(widget.postId);
                    final commentRef = postRef.collection('comments').doc();

                    final newComment = CommentModel(
                      id: commentRef.id,
                      postId: widget.postId,
                      userId: widget.userId,
                      commentText: _contentController.text.trim(),
                      commentImg: imgUrl,
                      createdAt: DateTime.now(),
                    );

                    // Lưu bình luận lên Firestore
                    await commentRef.set(newComment.toJson());

                    // Tải lại danh sách bình luận
                    context.read<CommentCubit>().loadComments(widget.postId);

                    // Xóa trạng thái preview và dọn dẹp nội dung
                    setState(() {
                      _contentController.clear();
                      _selectedImg = null;
                      context.read<CommentCubit>().updatePreviewStatus(false); // Reset preview
                    });
                  }
                },
              ),

            ],
          ),
        ],
      ),
    );
  }
}
