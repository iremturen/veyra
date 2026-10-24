import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:veyra/app/common/constants/app_colors.dart';
import 'package:veyra/app/common/constants/app_dimensions.dart';
import 'package:veyra/app/common/constants/app_font_size.dart';
import 'package:veyra/app/common/constants/app_strings.dart';
import 'package:veyra/app/common/models/custom_text_model.dart';
import 'package:veyra/app/common/widgets/custom_text.dart';
import 'package:veyra/presentation/pages/settings/crashlytics_test_page.dart';

class CrashlyticsDebugButton extends StatelessWidget {
  const CrashlyticsDebugButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return CupertinoButton(
      onPressed: () => Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => const CrashlyticsTestPage(),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingSmall,
      ),
      child: const CustomText(
        model: CustomTextModel(
          text: AppStrings.crashlyticsTest,
          style: TextStyle(color: AppColors.textSecondary),
          fontSize: AppFontSize.small,
        ),
      ),
    );
  }
}
