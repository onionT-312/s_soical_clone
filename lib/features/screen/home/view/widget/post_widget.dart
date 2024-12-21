import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:s_social/core/domain/model/post_model.dart';
import 'package:s_social/core/domain/model/user_model.dart';
import 'package:s_social/core/presentation/logic/cubit/profile_user/profile_user_cubit.dart';
import 'package:s_social/core/presentation/view/widgets/text_to_image.dart';
import 'package:s_social/core/utils/app_router/app_router.dart';
import 'package:s_social/core/utils/extensions/is_current_user.dart';
import 'package:s_social/core/utils/shimmer_loading.dart';
import 'package:s_social/core/utils/snack_bar.dart';
import 'package:s_social/core/utils/ui/cache_image.dart';
import 'package:s_social/features/screen/home/logic/post_cubit.dart';
import 'package:s_social/features/screen/home/view/post_screen.dart';
import 'package:s_social/features/screen/home/view/share_post_screen.dart';
import 'package:s_social/features/screen/home/view/widget/full_screen_img.dart';
import 'package:s_social/gen/assets.gen.dart';
import 'package:s_social/generated/l10n.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/domain/model/reaction_model.dart';
import '../../logic/reaction_cubit.dart';

class PostWidget extends StatefulWidget {
  final PostModel postData;
  final UserModel? userData;

  const PostWidget({
    super.key,
    required this.postData,
    required this.userData,
  });

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isReact = false;
  int reactCount = 0;

  @override
  void initState() {
    super.initState();
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

  Future<void> _sharePost() async {
    if (widget.postData.userId == null ||
        widget.postData.userId == currentUid) {
      context.showSnackBarFail(text: S.of(context).can_not_share_this_post);
      return;
    }

    final shouldReload = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => SharePostScreen(
          originalPostData: widget.postData.originalPost ?? widget.postData,
          originalUserData: widget.postData.originalUser ?? widget.userData!,
        ),
      ),
    );
    if (mounted && shouldReload == true) {
      context.read<PostCubit>().loadPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayName = widget.postData.userId != null
        ? (widget.userData?.username).toString()
        : S.of(context).anonymous;

    String formattedDate =
        DateFormat('dd/MM/yyyy HH:mm').format(widget.postData.createdAt!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar, username, and post time
        GestureDetector(
          onTap: () {
            if (widget.userData != null) {
              context.push("${RouterUri.profile}/${widget.userData!.id}");
            }
          },
          child: _buildPostHeader(
            context: context,
            displayName: displayName,
            datetime: formattedDate,
          ),
        ),
        _buildPostMessage(),
        if (widget.postData.originalPost != null) _buildOriginalPost(),
        _buildPostImage(context: context),
        _buildPostAction(context: context),
      ],
    );
  }

  Widget _buildPostHeader({
    required BuildContext context,
    required String displayName,
    required String datetime,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostUserAvatar(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  datetime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSecondaryFixed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostUserAvatar() {
    if (widget.postData.userId == null) {
      return Container(
        width: 40,
        height: 40,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.lightBlue,
        ),
        child: Image.asset(Assets.images.anonymous.path),
      );
    }

    if ((widget.userData?.avatarUrl ?? "").isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: CacheImage(
          imageUrl: widget.userData?.avatarUrl ?? "",
          loadingWidth: 40,
          loadingHeight: 40,
        ),
      );
    }
    return Container(
      width: 40,
      height: 40,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: TextToImage(
        text: (widget.userData?.username).toString()[0],
        textSize: 16.0,
      ),
    );
  }

  Widget _buildPostMessage() {
    if (widget.postData.postContent != null &&
        widget.postData.postContent!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Text(
          widget.postData.postContent!,
          style: const TextStyle(fontSize: 14),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildOriginalPost() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostScreen(
              postData: widget.postData.originalPost!,
              postUserData: widget.postData.originalUser,
            ),
          ),
        );
      },
      child: AbsorbPointer(
        child: Container(
          width: double.maxFinite,
          color: Theme.of(context).colorScheme.surfaceContainer,
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(8.0),
          child: PostWidget(
            postData: widget.postData.originalPost!,
            userData: widget.postData.originalUser,
          ),
        ),
      ),
    );
  }

  Widget _buildPostImage({
    required BuildContext context,
  }) {
    if (widget.postData.postImage != null &&
        widget.postData.postImage!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FullScreenImg(imageUrl: widget.postData.postImage!),
              ),
            );
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CacheImage(
                imageUrl: widget.postData.postImage ?? "",
                loadingWidth: constraints.maxWidth,
                loadingHeight: constraints.maxWidth * 0.6,
              );
            },
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPostAction({
    required BuildContext context,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPostItem(
          icon: isReact ? Icons.thumb_up : Icons.thumb_up_outlined,
          label: "$reactCount ${S.of(context).like}",
          color: isReact
              ? Colors.blue
              : Theme.of(context).colorScheme.onPrimaryFixed,
          onTap: _toggleReact,
        ),
        _buildPostItem(
          icon: Icons.comment_outlined,
          label: S.of(context).comment,
          color: Theme.of(context).colorScheme.onPrimaryFixed,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostScreen(
                  postData: widget.postData,
                  postUserData: widget.userData,
                ),
              ),
            );
          },
        ),
        _buildPostItem(
          icon: Icons.share_outlined,
          label: S.of(context).share,
          color: Theme.of(context).colorScheme.onPrimaryFixed,
          onTap: _sharePost,
        ),
      ],
    );
  }

  Widget _buildPostItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6.0),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerPost extends StatelessWidget {
  const ShimmerPost({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPostHeader(),
        _buildPostMessage(),
        _buildPostImage(),
        _buildPostAction(),
      ],
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade400,
            child: Container(
              width: 40,
              height: 40,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoading(
                  width: 70,
                  height: 16,
                ),
                SizedBox(height: 4),
                ShimmerLoading(
                  width: 50,
                  height: 14,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostMessage() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(
            width: 200,
            height: 18,
          ),
          SizedBox(height: 2.0),
          ShimmerLoading(
            width: 240,
            height: 18,
          ),
          SizedBox(height: 2.0),
          ShimmerLoading(
            width: 220,
            height: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: ShimmerLoading(
        width: double.maxFinite,
        height: 300,
      ),
    );
  }

  Widget _buildPostAction() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildActionItem(),
        _buildActionItem(),
        _buildActionItem(),
      ],
    );
  }

  Widget _buildActionItem() {
    return const Expanded(
      flex: 1,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: ShimmerLoading(
          width: 50,
          height: 30,
          borderRadius: 8.0,
        ),
      ),
    );
  }
}
