import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_family.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_font_weight.dart';
import 'package:veyra/app/common/constants/app_navigation_items.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_app_bar_model.dart';
import 'package:veyra/app/common/models/custom_navigation_bar_model.dart';
import 'package:veyra/app/common/models/custom_scaffold_model.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_app_bar.dart';
import 'package:veyra/app/common/widgets/custom_navigation_bar.dart';
import 'package:veyra/app/common/widgets/custom_scaffold.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/core/extensions/snack_bar_extension.dart';
import 'package:veyra/presentation/cubits/auth/auth_cubit.dart';
import 'package:veyra/presentation/cubits/explore/explore_banner_cubit.dart';
import 'package:veyra/presentation/cubits/feed/feed_cubit.dart';
import 'package:veyra/presentation/cubits/main/main_cubit.dart';
import 'package:veyra/presentation/cubits/notifications/notifications_cubit.dart';
import 'package:veyra/presentation/pages/auth/sign_in_page.dart';
import 'package:veyra/presentation/pages/explore/explore_page.dart';
import 'package:veyra/presentation/pages/notifications/notifications_page.dart';
import 'package:veyra/presentation/pages/post/create_post_page.dart';
import 'package:veyra/presentation/pages/profile/profile_page.dart';
import 'package:veyra/presentation/widgets/main/home_feed_view.dart';

Future<void> _pickImageThenCreatePost(BuildContext context) async {
  try {
    final imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: AppDimensions.createPostImageQuality,
    );
    if (!context.mounted || image == null) return;

    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => CreatePostPage(initialImage: image),
      ),
    );
  } catch (error) {
    debugPrint('Photo picker failed: $error');
    if (!context.mounted) return;
    context.showErrorSnackBar(AppStrings.photoSelectFailed);
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MainCubit()),
        BlocProvider(create: (_) => FeedCubit()..watchPosts()),
        BlocProvider(create: (_) => ExploreBannerCubit()..loadBanner()),
        BlocProvider(create: (_) => NotificationsCubit()..watchNotifications()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.signedOut) {
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute<void>(builder: (_) => const SignInPage()),
              (route) => false,
            );
          } else if (state.status == AuthStatus.failure) {
            context.showErrorSnackBar(state.message ?? '');
          }
        },
        child: const _HomeView(),
      ),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, int>(
      builder: (context, selectedIndex) {
        return CustomScaffold(
          model: CustomScaffoldModel(
            extendBody: true,
            appBar: CustomAppBar(
              model: CustomAppBarModel(
                title: _buildAppBarTitle(selectedIndex),
                automaticallyImplyLeading: false,
                showBottomBorder: true,
              ),
            ),
            body: IndexedStack(
              index: selectedIndex,
              children: const [
                HomeFeedView(),
                ExplorePage(),
                NotificationsPage(),
                ProfilePage(),
              ],
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacingMedium,
                  0,
                  AppDimensions.spacingMedium,
                  AppDimensions.spacingSmall,
                ),
                child: CustomNavigationBar(
                  model: CustomNavigationBarModel(
                    backgroundColor: AppColors.divider,
                    selectedIndex: selectedIndex,
                    items: AppNavigationItems.items,
                    onCreatePressed: () => _pickImageThenCreatePost(context),
                    onDestinationSelected: (index) =>
                        context.read<MainCubit>().changeTab(index),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBarTitle(int selectedIndex) {
    if (selectedIndex == 0 || selectedIndex == 1) {
      return const CustomText(
        model: CustomTextModel(
          text: AppStrings.appName,
          fontSize: AppFontSize.title,
          fontWeight: AppFontWeight.bold,
          fontFamily: AppFontFamily.brand,
          style: TextStyle(
            color: AppColors.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return CustomText(
      model: CustomTextModel(
        text: _tabTitle(selectedIndex),
        fontSize: AppFontSize.medium,
        fontWeight: AppFontWeight.normal,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
    );
  }

  String _tabTitle(int tabIndex) {
    if (tabIndex == 2) return AppStrings.navigationNotifications;
    return AppStrings.navigationProfile;
  }
}
