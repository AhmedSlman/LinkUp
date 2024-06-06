// ignore_for_file: prefer_const_constructors, non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/core/utils/app_colors.dart';
import 'package:linkup/feature/auth/data/user_model.dart';
import 'package:linkup/feature/auth/presentation/cubit/auth_cubit.dart';
import 'package:linkup/feature/chat/presentation/cubit/chat_cubit/chat_cubit.dart';
import 'package:linkup/feature/chat/presentation/view/all_chats_view.dart';
import 'package:linkup/feature/chat/presentation/view/all_users_page.dart';
import 'package:linkup/feature/profile/presntation/views/profile_page.dart';
import 'package:linkup/feature/settings/settings_page.dart';

int pageIndex = 0;

class NavigationBarButton extends StatefulWidget {
  const NavigationBarButton({
    super.key,
  });

  @override
  State<NavigationBarButton> createState() => _NavigationBarButtonState();
}

class _NavigationBarButtonState extends State<NavigationBarButton> {
  // int pageIndex = 0;
  final pageOption = [
    BlocProvider(
      create: (context) => ChatCubit(),
      child: AllChatsPage(),
    ),
    BlocProvider(
      create: (context) => ChatCubit(),
      child: AllUsersPage(),
    ),
    ProfilePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageOption[pageIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.borderColor))),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Dashbord',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Calls',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Profile',
            )
          ],
          backgroundColor: AppColors.backgroundColor,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 28,
          currentIndex: pageIndex,
          onTap: (int index) {
            setState(
              () {
                pageIndex = index;
              },
            );
          },
        ),
      ),
    );
  }
}
