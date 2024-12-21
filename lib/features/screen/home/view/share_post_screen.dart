import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s_social/core/domain/model/post_model.dart';
import 'package:s_social/core/domain/model/user_model.dart';
import 'package:s_social/core/presentation/logic/cubit/profile_user/profile_user_cubit.dart';
import 'package:s_social/core/utils/ui/dialog_loading.dart';
import 'package:s_social/di/injection_container.dart';
import 'package:s_social/features/screen/home/logic/post_cubit.dart';
import 'package:s_social/features/screen/home/view/post_screen.dart';
import 'package:s_social/features/screen/home/view/widget/post_widget.dart';
import 'package:s_social/generated/l10n.dart';

class SharePostScreen extends StatelessWidget {
  const SharePostScreen({
    super.key,
    required this.originalPostData,
    required this.originalUserData,
  });

  final PostModel originalPostData;
  final UserModel originalUserData;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PostCubit(
            postRepository: serviceLocator(),
            uploadFileRepository: serviceLocator(),
            userRepository: serviceLocator(),
          ),
        ),
      ],
      child: _SharePostScreen(
        originalPostData: originalPostData,
        originalUserData: originalUserData,
      ),
    );
  }
}

class _SharePostScreen extends StatefulWidget {
  const _SharePostScreen({
    required this.originalPostData,
    required this.originalUserData,
  });

  final PostModel originalPostData;
  final UserModel originalUserData;

  @override
  State<StatefulWidget> createState() => _SharePostScreenSate();
}

class _SharePostScreenSate extends State<_SharePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  String? username;
  String? userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(S.of(context).new_post),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              BlocBuilder<ProfileUserCubit, ProfileUserState>(
                builder: (context, state) {
                  if (state is ProfileUserLoaded) {
                    username = state.user.username;
                    userId = state.user.id;
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${S.of(context).post_by}: $username'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostScreen(
                        postData: widget.originalPostData,
                        postUserData: widget.originalUserData,
                      ),
                    ),
                  );
                },
                child: AbsorbPointer(
                  child: Container(
                    width: double.maxFinite,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    padding: const EdgeInsets.all(20.0),
                    child: PostWidget(
                      postData: widget.originalPostData,
                      userData: widget.originalUserData,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final shouldReload = await context.showDialogLoading<bool>(
                    future: () async {
                      final result = await context.read<PostCubit>().sharePost(
                            _contentController.text,
                            widget.originalPostData.id,
                            widget.originalUserData.id,
                          );

                      return result != null;
                    },
                  );

                  if (context.mounted) {
                    context.pop(shouldReload);
                  }
                },
                child: Text(S.of(context).post),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
