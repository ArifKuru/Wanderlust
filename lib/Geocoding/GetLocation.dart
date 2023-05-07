import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_geocoder/geocoder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wanderlust/EventFinder.dart';
import 'package:wanderlust/Firebasedemo.dart';
import 'package:wanderlust/currentCity.dart';
import 'package:wanderlust/location.dart';
import 'package:geolocator/geolocator.dart';

class GetLocation extends StatefulWidget {
  final int index;
  GetLocation({
    required this.index,
  });
  @override
  State<GetLocation> createState() => _GetLocationState();
}

class _GetLocationState extends State<GetLocation> {
  var locationMessage = "";
  dynamic latitude = 1.55;
  dynamic longitude = 2.544;
  bool _isLoading = true;

  void initState() {
    super.initState();
    getCurrentLocation();
  }

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

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = [
      TrapAdvisorHotels(
        latLng: LatLng(latitude, longitude),
      ),
      TrapAdvisorMuseums(
        latLng: LatLng(latitude, longitude),
      ),
      RestaurantList(
        position: LatLng(latitude, longitude),
      ),
    ];
    if (_isLoading) {
      return CircularProgressIndicator();
    } else {
      if (widget.index == 1) {
        return Container(child: _widgetOptions[0]);
      } else if (widget.index == 2) {
        return Container(child: _widgetOptions[1]);
      } else {
        return Container(child: _widgetOptions[2]);
      }
    }
  }
}
