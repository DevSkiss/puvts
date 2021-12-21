import 'dart:convert';
import 'package:puvts/app/locator_injection.dart';
import 'package:puvts/core/errors_exception/exceptions.dart';
import 'package:puvts/features/login_signup/data/service/auth_service_api.dart';
import 'package:puvts/features/login_signup/domain/passenger_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CachedService {
  Future<PassengerModel> getUser();

  Future<void> cacheUser(PassengerModel userToCache);

  Future<void> cacheToken({required String token});

  Future<String> getToken();

  Future<void> clearUser();
}

class CachedServiceImpl implements CachedService {
  final SharedPreferences prefs = locator<SharedPreferences>();
  final AuthApiService _authApiService = locator<AuthApiService>();

  @override
  Future<void> cacheToken({required String token}) {
    return prefs.setString('token', token);
  }

  @override
  Future<String> getToken() async {
    return prefs.getString('token') ?? '';
  }

  @override
  Future<PassengerModel> getUser() {
    final jsonString = prefs.getString('passenger');
    if (jsonString != null) {
      return Future.value(PassengerModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheUser(PassengerModel userToCache) {
    return prefs.setString(
      'passenger',
      json.encode(userToCache.toJson()),
    );
  }

  @override
  Future<void> clearUser() async {
    await _authApiService.logout();
    prefs.clear();
  }
}
