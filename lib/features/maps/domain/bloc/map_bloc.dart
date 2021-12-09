import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:puvts/app/locator_injection.dart';
import 'package:puvts/core/data/model/directions.dart';
import 'package:puvts/core/services/cached_services.dart';
import 'package:puvts/features/maps/data/model/location_dto.dart';
import 'package:puvts/features/maps/domain/bloc/map_state.dart';
import 'package:puvts/features/maps/domain/repositories/map_repositories.dart';

class MapBloc extends Cubit<MapState> {
  MapBloc() : super(MapState()) {
    initialize();
  }
  final MapRepository _mapRepository = locator<MapRepository>();
  final CachedService _cachedService = locator<CachedService>();

  void initialize() async {
    emit(state.copyWith(
      isLoading: true,
      hasError: false,
      noDriverFound: false,
      isSuccess: false,
    ));
    // get my location and save it as marker
    locationPermission();
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

  Future<void> getDriverLocation() async {
    emit(state.copyWith(isLoading: true));

    LocationDto driverLocation = await _mapRepository.getDriverLocation();
    emit(
      state.copyWith(
        isLoading: false,
        driverPosition: Marker(
          markerId: MarkerId('driverPosition'),
          infoWindow: InfoWindow(title: 'Driver'),
          position: LatLng(
            double.parse(driverLocation.latitude),
            double.parse(driverLocation.longitude),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      ),
    );
  }

  void getDirectionDriver() async {
    emit(state.copyWith(isLookingForDrivers: true));
    await getDriverLocation();

    Directions newDirection = await _mapRepository.getDirection(
      origin: state.myPosition?.position ?? defaultLatLong,
      destination: state.driverPosition?.position ?? defaultLatLong,
    );

    emit(state.copyWith(info: newDirection, isLookingForDrivers: false));
  }

  void locationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      forceAndroidLocationManager: true,
    );

    //_locationData = await location.getLocation();
    log('${newPosition.latitude}');
    emit(
      state.copyWith(
        isLoading: false,
        myPosition: Marker(
          markerId: MarkerId('myposition'),
          position: LatLng(
            newPosition.latitude,
            newPosition.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      ),
    );
  }

  void activateMyLocation() async {
    emit(state.copyWith(isSendingNewLocation: true));
    final passenger = await _cachedService.getUser();
    await _mapRepository.updateLocation(
      lat: state.myPosition?.position.latitude.toString() ?? '',
      lng: state.myPosition?.position.longitude.toString() ?? '',
      userId: passenger.id,
    );
    emit(state.copyWith(isSendingNewLocation: false));
  }
}
