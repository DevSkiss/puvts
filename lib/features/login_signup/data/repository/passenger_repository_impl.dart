import 'package:firebase_auth/firebase_auth.dart';
import 'package:puvts/app/locator_injection.dart';
import 'package:puvts/features/login_signup/data/service/auth_service_api.dart';
import 'package:puvts/features/login_signup/domain/passenger_model.dart';
import 'package:puvts/features/login_signup/domain/passenger_repository.dart';

class PassengerRepositoryImpl implements PassengerRepository {
  final AuthApiService _authApiService = locator<AuthApiService>();

  @override
  Future<UserCredential> loginPassenger(
      {required String email, required String password}) async {
    return await _authApiService.login(email: email, password: password);
  }

  @override
  Future<UserCredential> signupPassenger(
      {required String firstname,
      required String lastname,
      required String email,
      required String password}) async {
    return await _authApiService.signup(
      firstname: firstname,
      lastname: lastname,
      email: email,
      password: password,
    );
  }

  @override
  Future<PassengerModel> getDetails({required String userId}) async {
    return _authApiService.getDetails(id: userId);
  }
}
