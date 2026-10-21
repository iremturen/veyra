import 'package:flutter/cupertino.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_text_field_model.dart';
import 'package:veyra/app/common/widgets/custom_text_field.dart';

class ExploreSearchBar extends StatelessWidget {
  const ExploreSearchBar({this.onChanged, super.key});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      model: CustomTextFieldModel(
        hintText: AppStrings.exploreSearchHint,
        prefixIcon: CupertinoIcons.search,
        onChanged: onChanged,
      ),
    );
  }
}
