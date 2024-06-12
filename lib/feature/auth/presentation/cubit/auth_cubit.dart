import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:linkup/feature/auth/data/models/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? firstName;
  String? lastName;
  AuthCubit() : super(AuthInitial());

  void checkAuthState() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData = await _loadUserData(user.uid);
      emit(SignInSuccessState(user: user, userData: userData));
    } else {
      emit(AuthInitial());
    }
  }

  Future<UserModel> _loadUserData(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return UserModel.fromFirestore(doc);
  }

  void signUp(
    String email,
    String password,
    String? firstName,
    String? lastName,
  ) async {
    emit(SignUpLoadingState());
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user!.updateDisplayName(
        '$firstName $lastName',
      );
      await addUserProfile(userCredential.user!, firstName!, lastName!);
      final userData = await _loadUserData(userCredential.user!.uid);
      emit(SignUpSuccessState(user: userCredential.user!, userData: userData));
    } on FirebaseAuthException catch (e) {
      _sigUpHandelException(e);
    } catch (e) {
      emit(SignUpFailureState(errMessage: e.toString()));
    }
  }

  void signIn(String email, String password) async {
    emit(SignInLoadingState());
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userData = await _loadUserData(userCredential.user!.uid);
      emit(SignInSuccessState(user: userCredential.user!, userData: userData));
    } on FirebaseAuthException catch (e) {
      _sigInHandelException(e);
    } catch (e) {
      emit(SignInFailureState(errMessage: e.toString()));
    }
  }

  void signOut() async {
    await _auth.signOut();
    emit(AuthInitial());
  }

  void _sigUpHandelException(FirebaseAuthException e) {
    if (e.code == 'weak-password') {
      emit(
          SignUpFailureState(errMessage: 'The password provided is too weak.'));
    } else if (e.code == 'email-already-in-use') {
      emit(SignUpFailureState(
          errMessage: 'The account already exists for that email.'));
    } else if (e.code == 'invalid-email') {
      emit(SignUpFailureState(errMessage: 'The email is invalid.'));
    } else {
      emit(SignUpFailureState(errMessage: e.code));
    }
  }

  void _sigInHandelException(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      emit(SignInFailureState(errMessage: "No user found for that email."));
    } else if (e.code == 'wrong-password') {
      emit(SignInFailureState(
          errMessage: 'Wrong password provided for that user.'));
    } else {
      emit(SignInFailureState(errMessage: "Check your email and password."));
    }
  }

  Future<void> addUserProfile(
      User user, String firstName, String lastName) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users.doc(user.uid).set({
      "first_name": firstName,
      "last_name": lastName,
      "email": user.email,
      "photo_url": user.photoURL ?? '',
    });
  }

  Future<void> uploadProfilePicture(String userId, File imageFile) async {
    try {
      final ref =
          _storage.ref().child('user_profile_pictures').child('$userId.jpg');
      await ref.putFile(imageFile);

      final photoURL = await ref.getDownloadURL();

      await _firestore
          .collection('users')
          .doc(userId)
          .update({'photo_url': photoURL});

      final userData = await _loadUserData(userId);
      emit(SignInSuccessState(user: _auth.currentUser!, userData: userData));
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading profile picture: $e');
      }
    }
  }
}
