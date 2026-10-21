import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:veyra/app/common/constants/app_image_urls.dart';
import 'package:veyra/app/common/constants/app_strings.dart';

class ExploreBannerConfig {
  const ExploreBannerConfig({
    required this.title,
    required this.number,
    required this.imageUrl,
    required this.isHidden,
  });

  final String title;
  final int number;
  final String imageUrl;
  final bool isHidden;

  static const defaults = ExploreBannerConfig(
    title: AppStrings.exploreBannerDefaultTitle,
    number: 2026,
    imageUrl: AppImageUrls.onboardingStory,
    isHidden: false,
  );
}

class FirebaseRemoteConfigService {
  FirebaseRemoteConfigService({FirebaseRemoteConfig? remoteConfig})
    : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  static const String titleKey = 'explore_banner_title';
  static const String numberKey = 'explore_banner_number';
  static const String imageUrlKey = 'explore_banner_image_url';
  static const String isHiddenKey = 'explore_banner_is_hidden';

  final FirebaseRemoteConfig _remoteConfig;

  Future<ExploreBannerConfig> fetchExploreBanner() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 5),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await _remoteConfig.setDefaults({
      titleKey: ExploreBannerConfig.defaults.title,
      numberKey: ExploreBannerConfig.defaults.number,
      imageUrlKey: ExploreBannerConfig.defaults.imageUrl,
      isHiddenKey: ExploreBannerConfig.defaults.isHidden,
    });

    try {
      await _remoteConfig.fetchAndActivate();
    } catch (_) {
      // Cached values and the defaults remain available when fetching fails.
    }

    final configuredImageUrl = _remoteConfig.getString(imageUrlKey).trim();
    final configuredTitle = _remoteConfig.getString(titleKey).trim();

    return ExploreBannerConfig(
      title: configuredTitle.isEmpty
          ? ExploreBannerConfig.defaults.title
          : configuredTitle,
      number: _remoteConfig.getInt(numberKey),
      imageUrl: configuredImageUrl.isEmpty
          ? ExploreBannerConfig.defaults.imageUrl
          : configuredImageUrl,
      isHidden: _remoteConfig.getBool(isHiddenKey),
    );
  }
}
