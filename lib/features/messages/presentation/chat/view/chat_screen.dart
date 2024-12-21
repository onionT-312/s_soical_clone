import 'dart:core';
import 'dart:io';

import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:chat_bubbles/message_bars/message_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:s_social/core/data/data_source/push_notification_data_source.dart';
import 'package:s_social/core/domain/model/message_model.dart';
import 'package:s_social/di/injection_container.dart';
import 'package:s_social/features/messages/presentation/chat/logic/recipient_cubit.dart';
import 'package:s_social/features/messages/presentation/chat/logic/recipient_state.dart';
import 'package:s_social/features/messages/presentation/user_list/logic/user_list_cubit.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/domain/model/user_model.dart';
import '../../../../../core/utils/app_router/app_router.dart';
import '../../../../../core/utils/shimmer_loading.dart';
import '../../../../../generated/l10n.dart';
import '../../../../screen/home/view/widget/full_screen_img.dart';
import '../logic/chat_cubit.dart';

class ChatScreen extends StatelessWidget {
  final String? uid;

  const ChatScreen({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UserListCubit(
            chatRepository: serviceLocator(),
            friendRepository: serviceLocator(),
            userRepository: serviceLocator(),
            userListRepository: serviceLocator(),
          ),
        ),
        BlocProvider(
          create: (context) => ChatCubit(
            chatRepository: serviceLocator(),
            uploadFileRepository: serviceLocator(),
            userRepository: serviceLocator(),
            uid: uid,
          ),
        ),
        BlocProvider(
          create: (context) => RecipientCubit(
            userRepository: serviceLocator(),
          ),
        ),
      ],
      child: _ChatScreen(uid: uid),
    );
  }
}

class _ChatScreen extends StatefulWidget {
  const _ChatScreen({
    required String? uid,
  }) : _uid = uid;

  final String? _uid;

  @override
  State<_ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final messageCtrl = TextEditingController();
  final Stream<QuerySnapshot> _messageStream =
      FirebaseFirestore.instance.collection('messages').snapshots();
  final List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  UserModel? _recipient;

  @override
  void initState() {
    context.read<ChatCubit>().getChatSession(_chatId);
    getRecipientById(widget._uid!);
    super.initState();
  }

  @override
  Widget build(BuildContext buildContext) {
    final String chatId = _chatId;

    // Making a back button returning to the previous screen and a menu button that opens sideways
    return BlocBuilder<RecipientCubit, RecipientState>(
      builder: (blocBuilderContext, state) {
        if (state is RecipientLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is RecipientLoaded) {
          _recipient = state.user;
          return Scaffold(
            appBar: AppBar(
              title: Text(_recipient?.username ?? ''),
              automaticallyImplyLeading: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(buildContext);
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    // Open a menu
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: _buildContent(
                    buildContext: buildContext,
                  ),
                ),
                _buildMessageInput(),
              ],
            ),
          );
        } else if (state is RecipientError) {
          return Center(
            child: Text(state.error),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildContent({required BuildContext buildContext}) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return _buildChatLoading();
        } else if (state is ChatLoaded) {
          return _buildMessageList(
            buildContext: buildContext,
          );
        } else if (state is ChatError) {
          return Center(
            child: Text(state.error),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildMessageList({required BuildContext buildContext}) {
    return StreamBuilder(
      stream: buildContext.read<ChatCubit>().getMessageStream(_chatId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          final messages = snapshot.data!.docs
              .map((e) =>
                  MessageModel.fromJson(e.data() as Map<String, dynamic>))
              .toList();

          // Get the latest message
          final latestMessage = messages.isNotEmpty ? messages.last : null;

          // Update the user chat map
          if (latestMessage != null) {
            _updateUserChatMap(context, latestMessage);
          }

          return _buildMessageListView(
              messages: messages, buildContext: buildContext);
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildMessageListView(
      {required List<MessageModel> messages,
      required BuildContext buildContext}) {
    return ListView.builder(
      reverse: true,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        // If the previous message is from the same sender, don't show the sender's email
        int reversedIndex = messages.length - 1 - index;
        bool showSender = true;
        if (reversedIndex >= 1 &&
            messages[reversedIndex].senderEmail ==
                messages[reversedIndex - 1].senderEmail) {
          showSender = false;
        }
        return _buildMessageItem(
            message: messages[reversedIndex],
            showSender: showSender,
            msgContext: buildContext);
      },
    );
  }

  Widget _buildMessageInput() {
    final String chatId = _chatId;
    final String senderEmail = _auth.currentUser?.email ?? '';
    final String senderId = _auth.currentUser?.uid ?? '';

    final String recipientEmail = _recipient?.email ?? '';
    final String recipientId = _recipient?.id ?? '';
    final String? recipientFcmTokens = _recipient?.fcmTokens;

    List<String?>? urls = [];

    return MessageBar(
      messageBarHintText: S.of(context).type_message,
      onSend: (content) async {
        // If the message is empty, don't send
        if (content.isEmpty && _selectedImages.isEmpty) {
          return;
        }

        // Send images if exist to database
        if (_selectedImages.isNotEmpty) {
          urls = await context
              .read<ChatCubit>()
              .uploadImagesToFirebase(_selectedImages);
        }

        // Create a message model
        const uuid = Uuid();
        final message = MessageModel(
          messageId: uuid.v4(),
          senderEmail: senderEmail,
          recipientEmail: recipientEmail,
          content: content,
          images: urls,
          createdAt: DateTime.now(),
        );

        // Send message to the chat session
        await context
            .read<ChatCubit>()
            .sendMessage(chatId: chatId, message: message);

        // Send FCM notification to recipient
        await sendFCMMessage(
          fcmToken: recipientFcmTokens ?? "",
          title: senderEmail,
          body: content,
          route: "${RouterUri.chat}/$senderId",
        );

        // Clear the selected images
        _selectedImages.clear();
        urls?.clear();
      },
      actions: [
        InkWell(
          child: const Icon(
            Icons.add,
            color: Colors.black,
            size: 24,
          ),
          onTap: () {
            // Make ripple effect and do something (Not implemented)
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: InkWell(
            onTap: _pickImageFromGallery,
            child: const Icon(
              Icons.photo_library_outlined,
              color: Colors.green,
              size: 24,
            ),
          ),
        ),
      ], // Actions
    );
  }

  Future<void> _pickImageFromGallery() async {
    final String chatId = _chatId;
    final String senderEmail = _auth.currentUser?.email ?? '';
    final String senderId = _auth.currentUser?.uid ?? '';

    final String recipientEmail = _recipient?.email ?? '';
    final String recipientId = _recipient?.id ?? '';
    final String? recipientFcmTokens = _recipient?.fcmTokens;

    List<String?>? urls = [];

    _selectedImages.clear();
    final List<XFile?> pickedFile = await _imagePicker.pickMultiImage(
      imageQuality: 50,
      maxHeight: 1920,
      maxWidth: 1080,
    );
    setState(() async {
      if (pickedFile.isNotEmpty) {
        for (XFile? file in pickedFile) {
          if (file != null) {
            _selectedImages.add(File(file.path));
          }
        }
        urls = await context
            .read<ChatCubit>()
            .uploadImagesToFirebase(_selectedImages);

        // Create a message model
        const uuid = Uuid();
        final message = MessageModel(
          messageId: uuid.v4(),
          senderEmail: senderEmail,
          recipientEmail: recipientEmail,
          content: null,
          images: urls,
          createdAt: DateTime.now(),
        );

        // Send message to the chat session
        await context.read<ChatCubit>().sendMessage(
              chatId: chatId,
              message: message,
            );

        // Send FCM notification to recipient
        await sendFCMMessage(
          fcmToken: recipientFcmTokens ?? "",
          title: senderEmail,
          body: S.of(context).sent_some_images,
          route: "${RouterUri.chat}/$senderId",
        );

        // Clear the selected images
        _selectedImages.clear();
        urls?.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).no_image_selected),
          ),
        );
      }
    });
  }

  String get _chatId {
    final String currentUserId = _auth.currentUser?.uid ?? '';
    final String recipientId = widget._uid ?? '';
    List<String> userIds = [currentUserId, recipientId];
    userIds.sort();
    return userIds.join('-');
  }

  Widget _buildMessageItem(
      {required MessageModel message,
      required bool showSender,
      required BuildContext msgContext}) {
    Alignment alignment;
    Color color;
    CrossAxisAlignment crossAxisAlignment;
    MainAxisAlignment mainAxisAlignment;
    bool isSender;
    if (message.senderEmail == _auth.currentUser?.email) {
      alignment = Alignment.centerRight;
      color = Colors.blue[100]!;
      crossAxisAlignment = CrossAxisAlignment.end;
      mainAxisAlignment = MainAxisAlignment.end;
      isSender = true;
    } else {
      alignment = Alignment.centerLeft;
      color = Colors.grey[200]!;
      crossAxisAlignment = CrossAxisAlignment.start;
      mainAxisAlignment = MainAxisAlignment.start;
      isSender = false;
    }

    EdgeInsets edgeInsets = EdgeInsets.zero;
    bool showTail = false;
    if (showSender) {
      edgeInsets = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0);
      showTail = true;
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Reply to message
        if (details.primaryVelocity! < 0) {
          // Swiped left, make message do a swipe left animation
        }
      },
      onLongPress: () {
        // Show a menu to do things to message
        // Right now straight up delete the message
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(S.of(context).delete_message),
              content: Text(S.of(context).delete_message_confirmation),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(S.of(context).cancel),
                ),
                TextButton(
                  onPressed: () {
                    // Checking if its the sender of the message
                    if (message.senderEmail != _auth.currentUser?.email) {
                      // Return a snack bar saying you can't delete other people's messages
                      Navigator.pop(context);
                      return;
                    }
                    msgContext
                        .read<ChatCubit>()
                        .deleteMessage(message.messageId, _chatId);
                    Navigator.pop(context);
                  },
                  child: Text(S.of(context).delete),
                ),
              ],
            );
          },
        );
      },
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        children: [
          if (showSender)
            Padding(
              padding: edgeInsets,
              child: Text(message.senderEmail.toString() ?? ''),
            ),
          message.content != null
              ? BubbleSpecialOne(
                  isSender: isSender,
                  text: message.content ?? '',
                  color: color,
                  tail: showTail,
                )
              : Container(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
            child: _buildImages(
                images: message.images,
                edgeInsets: edgeInsets,
                crossAxisAlignment: crossAxisAlignment,
                mainAxisAlignment: mainAxisAlignment),
          ),
        ],
      ),
    );
  }

  // Make images show one by one in a column
  Widget _buildImages({
    required List<String?>? images,
    required EdgeInsets edgeInsets,
    required CrossAxisAlignment crossAxisAlignment,
    required MainAxisAlignment mainAxisAlignment,
  }) {
    if (images == null || images.isEmpty) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: images.map((e) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImg(
                  imageUrl: e ?? '',
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            child: Image.network(
              e ?? '',
              width: 200,
              height: 200,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _updateUserChatMap(BuildContext context, MessageModel message) async {
    final String currentUserId = _auth.currentUser?.uid ?? '';
    final String recipientId = _recipient?.id ?? '';
    await context.read<ChatCubit>().updateUserChatMap(
          currentUserId,
          recipientId,
          message,
        );
  }

  Future<void> getRecipientById(String id) async {
    await context.read<RecipientCubit>().getUserById(id);
  }

  Widget _buildChatLoading() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (iBContext, index) {
        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                width: 50,
                height: 50,
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const ShimmerLoading(width: 50, height: 50),
              ),
              const SizedBox(width: 8),
              // User information
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerLoading(width: 150, height: 18),
                  SizedBox(height: 4.0),
                  ShimmerLoading(width: 250, height: 16),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
