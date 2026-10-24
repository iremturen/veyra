import 'package:veyra/data/services/firebase_remote_config_service.dart';

class ExploreBannerState {
  const ExploreBannerState({
    this.config = ExploreBannerConfig.defaults,
    this.isLoading = false,
  });

  final ExploreBannerConfig config;
  final bool isLoading;
}
