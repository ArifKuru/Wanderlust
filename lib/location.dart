import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:search_map_place_updated/search_map_place_updated.dart';

class findLocation extends StatefulWidget {
  @override
  State<findLocation> createState() => findLocationState();
}

class findLocationState extends State<findLocation> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late CameraPosition _currentCameraPosition;

  LatLng? lastLocation;
  bool _isLoading = true;

  Map<String, LatLng> cities = {};
  String selectedCity = '';

  Future<void> _fetchFavCities() async {
    final user = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance
        .collection('Person')
        .doc(user!.uid)
        .collection('FavCities')
        .get();
    setState(() {
      cities = Map.fromEntries(snapshot.docs.map((doc) {
        final data = doc.data();
        final name = data['name'] as String;
        final latLng = data['location'] as GeoPoint;
        final lat = latLng.latitude;
        final lng = latLng.longitude;
        _isLoading = false;
        return MapEntry(name, LatLng(lat, lng));
      }));
      selectedCity = cities.keys.first;
      _currentCameraPosition =
          CameraPosition(target: cities[selectedCity]!, zoom: 14.0);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchFavCities();
  }

  Future<void> _goToSelectedCity() async {
    final GoogleMapController controller = await _controller.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(_currentCameraPosition));
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      lastLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CircularProgressIndicator();
    } else {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              cities.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : SearchMapPlaceWidget(
                      bgColor: Colors.white,
                      textColor: Colors.black,

                      apiKey: "*",
                      // The language of the autocompletion
                      language: 'en',
                      // The position used to give better recomendations. In this case we are using the user position
                      location: LatLng(39.9042, 116.4074),
                      radius: 30000,
                      onSelected: (Place place) async {
                        final geolocation = await place.geolocation;
                        setState(() {
                          lastLocation = geolocation!.coordinates;
                        });
                        // Will animate the GoogleMap camera, taking us to the selected position with an appropriate zoom
                        final GoogleMapController controller =
                            await _controller.future;
                        controller.animateCamera(
                            CameraUpdate.newLatLng(geolocation!.coordinates));
                        controller.animateCamera(CameraUpdate.newLatLngBounds(
                            geolocation!.bounds, 0));
                      },
                    ),
              Expanded(
                child: GoogleMap(
                  mapType: MapType.hybrid,
                  initialCameraPosition: _currentCameraPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  onTap: _onMapTapped,
                  markers: lastLocation == null
                      ? {}
                      : {
                          Marker(
                              markerId: const MarkerId("marker1"),
                              position: lastLocation!,
                              draggable: true,
                              onDragEnd: (value) {
                                setState(() {
                                  lastLocation = value;
                                });
                              }),
                        },
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: cities.isEmpty
                          ? const SizedBox
                              .shrink() // Hide dropdown when cities map is empty
                          : DropdownButton<String>(
                              value: selectedCity,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedCity = newValue!;
                                  _currentCameraPosition = CameraPosition(
                                    target: cities[selectedCity]!,
                                    zoom: 14.0,
                                  );
                                  lastLocation = cities[selectedCity];
                                });
                              },
                              items: cities.keys.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                    ),
                    const SizedBox(width: 8.0),
                    FloatingActionButton.extended(
                      backgroundColor: Colors.blue[800],
                      onPressed: _goToSelectedCity,
                      label: const Text('Go'),
                      icon: const Icon(
                        Icons.directions,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
