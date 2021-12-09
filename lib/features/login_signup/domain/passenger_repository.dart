import 'package:puvts/features/login_signup/data/model/passenger_auth_response_model.dart';
import 'package:puvts/features/login_signup/domain/passenger_model.dart';

abstract class PassengerRepository {
  Future<PassengerAuthResponseModel> loginPassenger(
      {required String username, required String password});

  Future<PassengerModel> signupPassenger({
    required String firstname,
    required String lastname,
    required String username,
    required String password,
  });
}
