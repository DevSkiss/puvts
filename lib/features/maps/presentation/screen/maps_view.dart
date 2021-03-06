import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:puvts/core/constants/puvts_colors.dart';
import 'package:puvts/core/widgets/puvts_button.dart';
import 'package:puvts/features/login_signup/presentation/screens/login_view.dart';
import 'package:puvts/features/maps/domain/bloc/map_bloc.dart';
import 'package:puvts/features/maps/domain/bloc/map_state.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapBloc(),
      child: MapsView(),
    );
  }
}

class MapsView extends StatefulWidget {
  const MapsView({Key? key}) : super(key: key);

  @override
  _MapsViewState createState() => _MapsViewState();
}

class _MapsViewState extends State<MapsView> {
  Location location = Location();
  LocationData? locationData;
  Timer? timer;
  LatLng? position;
  late StreamSubscription<LocationData> locationSub;
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(11.242034, 124.999902),
    zoom: 14.5,
  );
  GoogleMapController? _googleMapController;
  bool loading = false;

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) async {
      await getLocation();
      context.read<MapBloc>().updateMyLocation(
          latitude: locationData?.latitude ?? 11,
          longitude: locationData?.longitude ?? 124);
      if (context.read<MapBloc>().isFindMyDriverTapped) {
        context.read<MapBloc>().getDriverLocation();
      }
    });
    setState(() {
      position = LatLng(
        locationData?.latitude ?? 11,
        locationData?.longitude ?? 124,
      );
      _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: position ?? LatLng(11, 124),
            zoom: 16.5,
          ),
        ),
      );
    });
    super.initState();
  }

  void followMe() {
    setState(() {
      loading = true;
    });
    locationSub =
        location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        position = LatLng(
          currentLocation.latitude ?? 11,
          currentLocation.longitude ?? 124,
        );
        _googleMapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: position ?? LatLng(11, 124),
              zoom: 16.5,
            ),
          ),
        );
      });
    });
  }

  void cancelFollow() {
    setState(() {
      loading = false;
      locationSub.cancel();
    });
  }

  Future<void> getLocation() async {
    locationData = await location.getLocation();
  }

  @override
  void dispose() {
    locationSub.cancel();
    timer?.cancel();
    _googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapBloc, MapState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: puvtsWhite,
            centerTitle: true,
            title: Text(
              'Maps View',
              style: TextStyle(color: puvtsBlue),
            ),
            elevation: 0,
            toolbarHeight: 70,
            actions: [
              IconButton(
                  onPressed: () async {
                    log('Remove User');
                    await context.read<MapBloc>().logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      CupertinoPageRoute(
                        builder: (BuildContext context) {
                          return LoginView();
                        },
                      ),
                      (_) => false,
                    );
                  },
                  icon: Icon(
                    Icons.exit_to_app,
                    color: puvtsBlue,
                  ))
            ],
          ),
          body: state.isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    Expanded(
                      child: GoogleMap(
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: true,
                        initialCameraPosition: _initialCameraPosition,
                        onMapCreated: (controller) =>
                            _googleMapController = controller,
                        polylines: {
                          if (state.info != null)
                            Polyline(
                              polylineId: const PolylineId('direction'),
                              color: Colors.red,
                              width: 5,
                              points: state.info?.polylinePoints
                                      .map((e) =>
                                          LatLng(e.latitude, e.longitude))
                                      .toList() ??
                                  [],
                            )
                        },
                        markers: {
                          if (state.markers != null) ...state.markers!,
                          Marker(
                            markerId: MarkerId('driverPosition'),
                            infoWindow: InfoWindow(
                                title: state.driverDetails?.plateNumber),
                            position: state.driverPosition ??
                                LatLng(position?.latitude ?? 11,
                                    position?.longitude ?? 124),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueRed),
                          ),
                          Marker(
                            markerId: MarkerId('myPosition'),
                            infoWindow: InfoWindow(title: 'passenger'),
                            position: LatLng(position?.latitude ?? 11,
                                position?.longitude ?? 124),
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                                BitmapDescriptor.hueBlue),
                          ),
                        },
                      ),
                    ),
                    Visibility(
                        visible: state.info != null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: Text(
                              'Duration: ${state.info?.totalDuration} - Distance ${state.info?.totalDistance}'),
                        )),
                    if (state.info != null)
                      Text(
                          'Seat Available: ${state.driverDetails?.seatAvailable}'),
                    SizedBox(height: 15),
                    Text('${position?.latitude}, ${position?.longitude}'),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      color: Colors.transparent,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PuvtsButton(
                              text: 'Activate',
                              isLoading: loading,
                              buttonColor: puvtsBlue,
                              textColor: Colors.white,
                              height: 50,
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              borderColor: Colors.transparent,
                              onPressed: () {
                                if (loading) {
                                  cancelFollow();
                                } else {
                                  followMe();
                                }
                              }),
                          PuvtsButton(
                            text: 'Find Driver',
                            buttonColor: puvtsRed,
                            textColor: Colors.white,
                            isLoading: state.isLookingForDrivers,
                            height: 50,
                            borderColor: Colors.transparent,
                            onPressed: () {
                              context.read<MapBloc>().getDirectionDriver();
                              if (state.info != null) {
                                CameraUpdate.newLatLngBounds(
                                    state.info?.bounds ??
                                        LatLngBounds(
                                          southwest: LatLng(
                                              position?.latitude ?? 11,
                                              position?.longitude ?? 124),
                                          northeast: LatLng(
                                              position?.latitude ?? 11,
                                              position?.longitude ?? 124),
                                        ),
                                    100.0);
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
        );
      },
    );
  }
}
