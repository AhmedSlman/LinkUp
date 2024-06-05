// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:linkup/core/routes/routers.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_state.dart';
import 'package:linkup/feature/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:linkup/feature/auth/presentation/widgets/auth_text_form_field.dart';
import 'package:linkup/feature/auth/presentation/widgets/have_an_account.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    AuthCubit authCubit = BlocProvider.of<AuthCubit>(context);

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SignUpSuccessState) {
            context.go(Routers.allChats);
          } else if (state is SignUpFailuerState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errMessage)),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Create a new account",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  AuthTextFormField(
                    controller: _firstNameController,
                    hintText: 'First Name',
                    onChanged: (firstName) {
                      authCubit.firstName = firstName;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  AuthTextFormField(
                    controller: _lastNameController,
                    hintText: 'Last Name',
                    onChanged: (lastName) {
                      authCubit.lastName = lastName;
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  AuthTextFormField(
                    controller: _emailController,
                    hintText: 'Email',
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  AuthTextFormField(
                    controller: _passwordController,
                    hintText: 'Password',
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state is SignUpLoadingState) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return AuthGradientButton(
                          text: 'Sign Up',
                          onTap: () {
                            authCubit.signUp(
                              _emailController.text,
                              _passwordController.text,
                            );
                          },
                        );
                      }
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  HaveAnAcountWidget(
                    text1: 'Already have an account?',
                    text2: ' Login ',
                    onTab: () {
                      context.go(Routers.login);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
