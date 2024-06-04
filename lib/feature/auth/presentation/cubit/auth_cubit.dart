import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthCubit() : super(AuthInitial());

  String? firstName;
  String? lastName;
  String? emailAddress;

  void checkAuthState() async {
    final user = _auth.currentUser;
    if (user != null) {
      emit(
          SignInSuccessState(user: user)); // Assuming user is already signed in
    } else {
      emit(AuthInitial());
    }
  }

  void signUp(String email, String password) async {
    emit(SignUpLoadingState());
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await addUserProfile(userCredential.user!);
      emit(SignUpSuccessState());
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
          email: email, password: password);
      emit(SignInSuccessState(user: userCredential.user!));
    } on FirebaseAuthException catch (e) {
      _sigInHandelException(e);
    } catch (e) {
      emit(SignInFailuerState(errMessage: e.toString()));
    }
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

  void signOut() async {
    await _auth.signOut();
    emit(AuthInitial());
  }

  void resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> deleteAccount() async {
    await _auth.currentUser!.delete();
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser!.sendEmailVerification();
  }

  Future<void> addUserProfile(User user) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    await users.doc(user.uid).set({
      "first_name": firstName,
      "last_name": lastName,
      "email": user.email,
    });
  }

  Future<Stream<List<Map<String, dynamic>>>> getAllUsers() async {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }
}
