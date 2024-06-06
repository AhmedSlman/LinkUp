import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:linkup/feature/auth/data/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      emit(SignUpFailuerState(errMessage: e.toString()));
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
      emit(SignInFailuerState(errMessage: e.toString()));
    }
  }

  void signOut() async {
    await _auth.signOut();
    emit(AuthInitial());
  }

  void _sigUpHandelException(FirebaseAuthException e) {
    if (e.code == 'weak-password') {
      emit(
          SignUpFailuerState(errMessage: 'The password provided is too weak.'));
    } else if (e.code == 'email-already-in-use') {
      emit(SignUpFailuerState(
          errMessage: 'The account already exists for that email.'));
    } else if (e.code == 'invalid-email') {
      emit(SignUpFailuerState(errMessage: 'The email is invalid.'));
    } else {
      emit(SignUpFailuerState(errMessage: e.code));
    }
  }

  void _sigInHandelException(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      emit(SignInFailuerState(errMessage: "No user found for that email."));
    } else if (e.code == 'wrong-password') {
      emit(SignInFailuerState(
          errMessage: 'Wrong password provided for that user.'));
    } else {
      emit(SignInFailuerState(errMessage: "Check your email and password."));
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
}
