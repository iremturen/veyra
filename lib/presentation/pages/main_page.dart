import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
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
import 'package:veyra/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:veyra/data/repositories/auth_repository_impl.dart';
import 'package:veyra/presentation/cubits/auth_cubit.dart';
import 'package:veyra/presentation/cubits/explore_banner_cubit.dart';
import 'package:veyra/presentation/cubits/feed_cubit.dart';
import 'package:veyra/presentation/cubits/main_cubit.dart';
import 'package:veyra/presentation/pages/create_post_page.dart';
import 'package:veyra/presentation/pages/explore_page.dart';
import 'package:veyra/presentation/pages/notifications_page.dart';
import 'package:veyra/presentation/pages/profile_page.dart';
import 'package:veyra/presentation/pages/register_page.dart';
import 'package:veyra/presentation/widgets/main/home_feed_view.dart';

final _imagePicker = ImagePicker();

Future<void> _pickImageThenCreatePost(BuildContext context) async {
  try {
    final image = await _imagePicker.pickImage(
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppStrings.photoSelectFailed)));
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
        BlocProvider(
          create: (_) => AuthCubit(
            AuthRepositoryImpl(dataSource: FirebaseAuthDataSource()),
          ),
        ),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.signedOut) {
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute<void>(builder: (_) => const RegisterPage()),
              (route) => false,
            );
          } else if (state.status == AuthStatus.failure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message!)));
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
                title: selectedIndex == 0 || selectedIndex == 1
                    ? CustomText(
                        model: CustomTextModel(
                          text: AppStrings.appName,
                          fontSize: AppFontSize.title,
                          fontWeight: AppFontWeight.bold,
                          fontFamily: AppFontFamily.brand,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : CustomText(
                        model: CustomTextModel(
                          text: _tabTitle(selectedIndex),
                          fontSize: AppFontSize.medium,
                          fontWeight: AppFontWeight.normal,
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
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
                    selectedIndex: _navigationIndex(selectedIndex),
                    items: AppNavigationItems.items,
                    onCreatePressed: () => _pickImageThenCreatePost(context),
                    onDestinationSelected: (index) => context
                        .read<MainCubit>()
                        .changeTab(_tabIndexForNavigation(index)),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

int? _navigationIndex(int tabIndex) {
  return tabIndex;
}

int _tabIndexForNavigation(int navigationIndex) {
  return navigationIndex;
}

String _tabTitle(int tabIndex) {
  if (tabIndex == 1) return AppStrings.exploreTitle;
  if (tabIndex == 2) return AppStrings.navigationNotifications;
  return AppStrings.navigationProfile;
}
