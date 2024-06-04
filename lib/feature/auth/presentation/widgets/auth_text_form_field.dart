import 'package:flutter/material.dart';

class AuthTextFormField extends StatelessWidget {
  const AuthTextFormField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isOscureText = false,
    this.onChanged,
  });
  final String hintText;
  final TextEditingController controller;
  final bool isOscureText;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color.fromARGB(255, 193, 201, 218),
          fontWeight: FontWeight.w300,
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return "$hintText is missing";
        }
        return null;
      },
      obscureText: isOscureText,
    );
  }
}
