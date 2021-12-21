import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puvts/app/locator_injection.dart';
import 'package:puvts/core/services/cached_services.dart';
import 'package:puvts/features/login_signup/domain/bloc/login_signup_state.dart';
import 'package:puvts/features/login_signup/domain/passenger_model.dart';
import 'package:puvts/features/login_signup/domain/passenger_repository.dart';

class LoginSignupBloc extends Cubit<LoginSignupState> {
  LoginSignupBloc() : super(LoginSignupState()) {
    initial();
  }

  final PassengerRepository _userRepository = locator<PassengerRepository>();
  final CachedService _cachedService = locator<CachedService>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void initial() async {
    emit(state.copyWith(
      isLoading: true,
      isCached: false,
      finished: false,
    ));
    try {
      PassengerModel? user = await _cachedService.getUser();
      if (user.id != '') {
        emit(state.copyWith(isCached: true, isLoading: false));
      } else {
        emit(state.copyWith(isCached: false, isLoading: false));
      }
    } catch (e) {
      log('errors here?');
      emit(state.copyWith(
        isLoading: false,
      ));
    }
  }

  void showHidePassword() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void login({required String email, required String password}) async {
    emit(state.copyWith(
      isLoading: true,
      hasError: false,
      finished: false,
    ));
    try {
      UserCredential authResult = await _userRepository.loginPassenger(
          email: email, password: password);

      PassengerModel userDetails =
          await _userRepository.getDetails(userId: authResult.user?.uid ?? '');

      if (authResult.user.toString() != '') {
        _cachedService.cacheUser(userDetails);
      }
      //   _cachedService.cacheUser(authResult.passenger!);
      CollectionReference location =
          FirebaseFirestore.instance.collection('location');

      var result = await firestore
          .collection('location')
          .where('user_id', isEqualTo: userDetails.id)
          .where('user_type', isEqualTo: 'passenger')
          .get();

      location
          .doc(result.docs[0].id)
          .update({'active': true})
          .then((value) => print("Passenger InActive"))
          .catchError((error) => print("Failed to update location: $error"));
      emit(state.copyWith(
        isLoading: false,
        finished: true,
      ));
    } catch (e) {
      log('Catch Password');
      emit(state.copyWith(isLoading: false, hasError: true));
      log(e.toString());
    }
  }

  void signup({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(
      isLoading: true,
      hasError: false,
      finished: false,
    ));
    try {
      CollectionReference location =
          FirebaseFirestore.instance.collection('location');
      UserCredential user = await _userRepository.signupPassenger(
        firstname: firstname,
        lastname: lastname,
        email: email,
        password: password,
      );

      location.add({
        'firstname': firstname,
        'lastname': lastname,
        'user_id': user.user?.uid,
        'user_type': 'passenger',
        'active': true,
        'latitude': '',
        'longitude': '',
      });

      emit(state.copyWith(
        finished: true,
        isLoading: false,
      ));
    } catch (e) {
      debugPrint('catch error $e');
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
      ));
    }
  }
}
