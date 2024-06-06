import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:linkup/core/routes/routers.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_state.dart';
import 'package:linkup/feature/auth/presentation/widgets/auth_gradient_button.dart';
import 'package:linkup/feature/auth/presentation/widgets/auth_text_form_field.dart';
import 'package:linkup/feature/auth/presentation/widgets/have_an_account.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SignInSuccessState) {
            context.go(Routers.navigationBottom);
          } else if (state is SignInFailuerState) {
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
                      "Welcme Back!",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  AuthTextFormField(
                    controller: _emailController,
                    hintText: 'Email',
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  AuthTextFormField(
                    controller: _passwordController,
                    hintText: 'Password',
                    isOscureText: true,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state is SignInLoadingState) {
                        return const CircularProgressIndicator();
                      } else {
                        return AuthGradientButton(
                          text: 'Sign In',
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthCubit>().signIn(
                                    _emailController.text,
                                    _passwordController.text,
                                  );
                            }
                          },
                        );
                      }
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  HaveAnAcountWidget(
                    text1: 'Don\'t have an account?',
                    text2: ' Sign Up',
                    onTab: () {
                      context.go(Routers.signUp);
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
