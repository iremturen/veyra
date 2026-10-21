import 'package:flutter_bloc/flutter_bloc.dart';

class MainCubit extends Cubit<int> {
  MainCubit() : super(0);

  void changeTab(int index) {
    if (index < 0 || index > 3 || index == state) return;
    emit(index);
  }
}
