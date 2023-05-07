import 'package:flutter/material.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class YourMap extends StatefulWidget {
  const YourMap({Key? key}) : super(key: key);

  @override
  State<YourMap> createState() => _YourMapState();
}

class _YourMapState extends State<YourMap> {
  dynamic latitude = 1.55;
  dynamic longitude = 2.44;
  late GoogleMapController _controller;

  void initState() {
    super.initState();
    getCurrentLocation();
  }

  var locationMessage = "";
  bool _isLoading = true;
  void getCurrentLocation() async {
    try {
      var position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      var lastPosition = await Geolocator.getLastKnownPosition();
      print(lastPosition);
      final coordinates =
          new Coordinates(position.latitude, position.longitude);
      setState(() {
        locationMessage =
            "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
        latitude = position.latitude;
        longitude = position.longitude;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  void _onMarkerDragEnd(LatLng position) {
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
    _controller.animateCamera(CameraUpdate.newLatLng(position));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CircularProgressIndicator();
    } else {
      return Container(
        height: 240,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            zoom: 14.0,
            target: LatLng(latitude, longitude),
          ),
          markers: {
            Marker(
              markerId: MarkerId('marker'),
              position: LatLng(latitude, longitude),
              draggable: true,
              onDragEnd: _onMarkerDragEnd,
            ),
          },
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
          },
          onTap: _onMapTapped,
        ),
      );
    }
  }
}
