import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/custom_scaffold_model.dart';

class CustomScaffold extends StatelessWidget {
  final CustomScaffoldModel model;

  const CustomScaffold({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: model.appBar,
      extendBody: model.extendBody,
      body: model.safeArea ? SafeArea(child: model.body) : model.body,
      bottomNavigationBar: model.bottomNavigationBar,
      floatingActionButton: model.floatingActionButton,
      backgroundColor: model.backgroundColor ?? AppColors.background,
      resizeToAvoidBottomInset: model.resizeToAvoidBottomInset,
    );
  }
}
