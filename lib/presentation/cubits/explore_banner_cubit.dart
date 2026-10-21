import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veyra/data/services/firebase_remote_config_service.dart';

class ExploreBannerState {
  const ExploreBannerState({
    this.config = ExploreBannerConfig.defaults,
    this.isLoading = false,
  });

  final ExploreBannerConfig config;
  final bool isLoading;
}

class ExploreBannerCubit extends Cubit<ExploreBannerState> {
  ExploreBannerCubit({FirebaseRemoteConfigService? service})
    : _service = service ?? FirebaseRemoteConfigService(),
      super(const ExploreBannerState());

  final FirebaseRemoteConfigService _service;

  Future<void> loadBanner() async {
    emit(ExploreBannerState(config: state.config, isLoading: true));
    try {
      final config = await _service.fetchExploreBanner();
      if (!isClosed) emit(ExploreBannerState(config: config));
    } catch (_) {
      if (!isClosed) {
        emit(const ExploreBannerState(config: ExploreBannerConfig.defaults));
      }
    }
  }
}
