// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:linkup/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  Future<void> _pickImage(BuildContext context, String userId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      context.read<AuthCubit>().uploadProfilePicture(userId, imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is SignInSuccessState) {
            final user = state.user;
            final userData = state.userData;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userData.photoURL.isNotEmpty
                      ? CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(userData.photoURL),
                        )
                      : const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person, size: 50),
                        ),
                  const SizedBox(height: 20),
                  Text(
                    'First Name: ${userData.firstName}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Last Name: ${userData.lastName}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Email: ${user.email ?? 'N/A'}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _pickImage(context, user.uid),
                    child: const Text('Change Profile Picture'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<AuthCubit>(context).signOut();
                    },
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
