import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:puvts/core/errors_exception/exceptions.dart';
import 'package:puvts/features/login_signup/domain/passenger_model.dart';

abstract class AuthApiService {
  Future<UserCredential> login(
      {required String email, required String password});

  Future<UserCredential> signup(
      {required String firstname,
      required String lastname,
      required String email,
      required String password});
  Future<void> logout();

  Future<PassengerModel> getDetails({required String id});
}

class AuthApiServiceImpl extends AuthApiService {
  //var client = http.Client();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<void> logout() async {
    await auth.signOut();
  }

  @override
  Future<UserCredential> login(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
        throw FirebaseAuthException(code: '404');
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided for that user.');
        throw FirebaseAuthException(code: '401');
      }
    }
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signup(
      {required String firstname,
      required String lastname,
      required String email,
      required String password}) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return users
          .add({
            'user_id': userCredential.user?.uid,
            'firstname': firstname,
            'lastname': lastname,
            'email': email,
            'active': true,
            'user_type': 'passenger',
          })
          .then((value) => userCredential)
          .catchError((error) => throw UserAlreadyExisting);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak.');
        throw FirebaseAuthException(code: 'weak-password');
      } else if (e.code == 'email-already-in-use') {
        debugPrint('The account already exists for that email.');
        throw FirebaseAuthException(code: 'email-already-in-use');
      }
    } catch (e) {
      debugPrint(e.toString());
      throw UnimplementedError();
    }
    throw UnimplementedError();
  }

  @override
  Future<PassengerModel> getDetails({required String id}) async {
    try {
      var result = await firestore
          .collection('users')
          .where('user_id', isEqualTo: id)
          .get();
      return PassengerModel.fromJson(result.docs[0].data());
    } on FirebaseAuthException {
      throw UnimplementedError();
    }
  }
}
