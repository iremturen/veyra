import 'package:flutter/material.dart';

import '../models/custom_icon_model.dart';

class CustomIcon extends StatelessWidget {
  final CustomIconModel model;

  const CustomIcon({required this.model, super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(model.icon, size: model.size, color: model.color);
  }
}
