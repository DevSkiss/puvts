import 'package:puvts/app/locator_injection.dart';
import 'package:puvts/features/login_signup/data/model/passenger_auth_response_model.dart';
import 'package:puvts/features/login_signup/data/service/auth_service_api.dart';
import 'package:puvts/features/login_signup/domain/passenger_model.dart';
import 'package:puvts/features/login_signup/domain/passenger_repository.dart';

class PassengerRepositoryImpl implements PassengerRepository {
  final AuthApiService _authApiService = locator<AuthApiService>();

  @override
  Future<PassengerAuthResponseModel> loginPassenger(
      {required String username, required String password}) async {
    return await _authApiService.login(username: username, password: password);
  }

  @override
  Future<PassengerModel> signupPassenger(
      {required String firstname,
      required String lastname,
      required String username,
      required String password}) async {
    return await _authApiService.signup(
      firstname: firstname,
      lastname: lastname,
      username: username,
      password: password,
    );
  }
}
