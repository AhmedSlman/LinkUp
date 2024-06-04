// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:linkup/core/utils/app_styles.dart';

class AuthGradientButton extends StatelessWidget {
  const AuthGradientButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(200, 55),
          backgroundColor: const Color(0xff3B73E8),
        ),
        child: Text(
          text,
          style: AppStyles.s20,
        ),
      ),
    );
  }
}
