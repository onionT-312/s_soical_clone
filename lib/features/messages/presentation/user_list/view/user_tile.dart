import 'package:flutter/material.dart';

import '../../../../../core/domain/model/message_model.dart';
import '../../../../../core/domain/model/user_model.dart';
import '../../../../../core/presentation/view/widgets/text_to_image.dart';
import '../../../../../core/utils/ui/cache_image.dart';
import '../../../../../generated/l10n.dart';

class UserTile extends StatelessWidget {
  final UserModel? user;
  final MessageModel? latestMessage;
  final void Function()? onTap;

  const UserTile({
    super.key,
    required this.user,
    required this.onTap,
    required this.latestMessage,
  });

  @override
  Widget build(BuildContext context) {
    final String userName = user?.username ?? S.of(context).no_username;
    final String userEmail = user?.email ?? S.of(context).no_email;
    final userAvatarUrl = user?.avatarUrl ?? "https://via.placeholder.com/150";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            _buildAvatarImage(
              context: context,
              avatarUrl: userAvatarUrl,
              username: userName,
            ),
            const SizedBox(width: 8),
            // User information
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                _buildLastMessage(context, latestMessage, userEmail),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarImage({
    required BuildContext context,
    String? avatarUrl,
    String? username,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Container(
        clipBehavior: Clip.hardEdge,
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: (avatarUrl ?? "").isNotEmpty
            ? SizedBox(
                width: 50,
                height: 50,
                child: CacheImage(
                  imageUrl: avatarUrl ?? "",
                  loadingWidth: 50,
                  loadingHeight: 50,
                ),
              )
            : TextToImage(
                text: username?[0].toUpperCase() ?? "S",
              ),
      ),
    );
  }

  Widget _buildLastMessage(
      BuildContext context, MessageModel? latestMessage, String userEmail) {
    if (latestMessage == null) {
      return const SizedBox();
    }

    if (latestMessage.content != null) {
      return Text(
        latestMessage.senderEmail == userEmail
            ? latestMessage.content!
            : "${S.of(context).you}: ${latestMessage.content}",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (latestMessage.images != null) {
      return Text(
        latestMessage.senderEmail == userEmail
            ? S.of(context).sent_some_images
            : S.of(context).you_sent_some_images,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return const SizedBox();
  }
}
