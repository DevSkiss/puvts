import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:puvts/app/locator_injection.dart';
import 'package:puvts/core/data/model/directions.dart';
import 'package:puvts/core/services/cached_services.dart';
import 'package:puvts/core/services/notification_service.dart';
import 'package:puvts/features/login_signup/domain/passenger_model.dart';
import 'package:puvts/features/maps/data/model/location_dto.dart';
import 'package:puvts/features/maps/domain/bloc/map_state.dart';
import 'package:puvts/features/maps/domain/repositories/map_repositories.dart';

class MapBloc extends Cubit<MapState> {
  MapBloc() : super(MapState()) {
    initialize();
  }
  final MapRepository _mapRepository = locator<MapRepository>();
  final CachedService _cachedService = locator<CachedService>();
  final NotificationHelper _notificationService = locator<NotificationHelper>();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamSubscription<LocationData>? locationSub;

  Location location = new Location();

  void initialize() async {
    emit(state.copyWith(
      isLoading: true,
      hasError: false,
      noDriverFound: false,
      isSuccess: false,
    ));
    // get my location and save it as marker
    await locationPermission();
  }

  void resetState() {
    emit(state.copyWith(
      isLoading: false,
      hasError: false,
      noDriverFound: false,
      isSuccess: false,
      driverPosition: null,
      info: null,
    ));
  }

  LatLng defaultLatLong = LatLng(11.242034, 124.999902);

  Future<LatLng> getDriverLocation() async {
    try {
      emit(state.copyWith(isLoading: true));

      var result = await firestore
          .collection('location')
          .where('user_type', isEqualTo: 'driver')
          .get();

      LocationDto driverLocation = LocationDto.fromJson(result.docs[0].data());

      emit(state.copyWith(driverDetails: driverLocation));
      return LatLng(double.parse(driverLocation.latitude),
          double.parse(driverLocation.longitude));
    } catch (e) {
      debugPrint(e.toString());
      throw UnimplementedError();
    }
  }

  Future<void> logout() async {
    try {
      CollectionReference location =
          FirebaseFirestore.instance.collection('location');
      PassengerModel passenger = await _cachedService.getUser();

      var result = await firestore
          .collection('location')
          .where('user_id', isEqualTo: passenger.id)
          .where('user_type', isEqualTo: 'passenger')
          .get();

      location
          .doc(result.docs[0].id)
          .update({'active': false})
          .then((value) => print("Passenger InActive"))
          .catchError((error) => print("Failed to update location: $error"));
      locationSub?.cancel();
      await _cachedService.clearUser();
    } catch (e) {
      debugPrint(e.toString());
      throw UnimplementedError();
    }
  }

  void updateMyLocation(
      {required double longitude, required double latitude}) async {
    try {
      CollectionReference location =
          FirebaseFirestore.instance.collection('location');
      PassengerModel passenger = await _cachedService.getUser();

      var result = await firestore
          .collection('location')
          .where('user_id', isEqualTo: passenger.id)
          .where('user_type', isEqualTo: 'passenger')
          .get();

      location
          .doc(result.docs[0].id)
          .update({
            'longitude': longitude.toString(),
            'latitude': latitude.toString(),
          })
          .then((value) => print("Location Updated"))
          .catchError((error) => print("Failed to update location: $error"));
    } catch (e) {
      debugPrint(e.toString());
      throw UnimplementedError();
    }
  }

  void getDirectionDriver() async {
    try {
      emit(state.copyWith(isLookingForDrivers: true));
      LatLng driverLocation = await getDriverLocation();

      Directions newDirection = await _mapRepository.getDirection(
        origin: state.myPosition ?? defaultLatLong,
        destination: driverLocation,
      );
      log('this gets run');
      _notificationService.showNormalNotification(
        title: 'PUV Tracking System',
        body:
            'PUV is near only ${newDirection.totalDistance} and approximately ${newDirection.totalDuration} left',
        payload: 'This is a tests',
      );
      emit(state.copyWith(
          info: newDirection,
          driverPosition: driverLocation,
          isLookingForDrivers: false));
    } catch (e) {
      log('no route found');
      emit(state.copyWith(hasError: true, isLookingForDrivers: false));
    }
  }

  Future<void> locationPermission() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationSub =
        location.onLocationChanged.listen((LocationData currentLocation) {
      emit(
        state.copyWith(
            isLoading: false,
            myPosition: LatLng(
              currentLocation.latitude ?? 11,
              currentLocation.longitude ?? 124,
            )),
      );
    });
  }

  void activateMyLocation() async {
    emit(state.copyWith(isSendingNewLocation: true));
    final passenger = await _cachedService.getUser();
    await _mapRepository.updateLocation(
      lat: state.myPosition?.latitude.toString() ?? '',
      lng: state.myPosition?.longitude.toString() ?? '',
      userId: passenger.id,
    );
    emit(state.copyWith(isSendingNewLocation: false));
  }
}
