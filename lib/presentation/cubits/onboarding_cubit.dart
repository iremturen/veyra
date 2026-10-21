import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingCubit extends Cubit<int> {
  OnboardingCubit() : super(0);

  void changePage(int index) {
    emit(index);
  }

  void nextPage() {
    if (state < 2) {
      emit(state + 1);
    }
  }

  void previousPage() {
    if (state > 0) {
      emit(state - 1);
    }
  }
}
