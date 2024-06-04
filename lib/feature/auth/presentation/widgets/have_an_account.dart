import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';

class HaveAnAcountWidget extends StatelessWidget {
  const HaveAnAcountWidget({
    super.key,
    required this.text1,
    required this.text2,
    this.onTab,
  });
  final String text1;
  final String text2;
  final VoidCallback? onTab;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTab,
      child: RichText(
        text: TextSpan(
            text: text1,
            style: Theme.of(context).textTheme.titleMedium,
            children: [
              TextSpan(
                text: text2,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.whiteColor, fontWeight: FontWeight.bold),
              )
            ]),
      ),
    );
  }
}
