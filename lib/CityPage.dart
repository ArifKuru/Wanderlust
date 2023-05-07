import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wanderlust/EventFinder.dart';
import 'package:wanderlust/Firebasedemo.dart';

class CityDetailPage extends StatefulWidget {
  final String cityName;
  final String imageUrl;
  final GeoPoint location;

  CityDetailPage(
      {required this.cityName, required this.imageUrl, required this.location});

  @override
  _CityDetailPageState createState() => _CityDetailPageState();
}

class _CityDetailPageState extends State<CityDetailPage> {
  LatLng? _latLng;
  late GoogleMapController _controller;
  static Map<String, dynamic> _weatherData = {};
  static bool _isLoading = true;
  LatLng _markerLocation = LatLng(0, 0);
  @override
  Future<void> _loadWeatherData(GeoPoint location) async {
    setState(() {
      _isLoading = true;
    });

    final String apiKey = '*';
    final String apiUrl = 'https://api.openweathermap.org/data/2.5/weather';

    final url =
        '$apiUrl?lat=${location.latitude}&lon=${location.longitude}&appid=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      setState(() {
        _weatherData = decodedData;
      });
    } else {
      print('Error fetching weather data: ${response.statusCode}');
    }

    setState(() {
      _isLoading = false;
    });
  }

  static int _selectedIndex = 0;
  static List<Widget> _widgetOptions = [];
  @override
  void initState() {
    super.initState();
    _markerLocation =
        LatLng(widget.location.latitude, widget.location.longitude);
    _widgetOptions = [
      TrapAdvisorHotels(
        latLng: LatLng(widget.location.latitude, widget.location.longitude),
      ),
      TrapAdvisorMuseums(
        latLng: LatLng(widget.location.latitude, widget.location.longitude),
      ),
      RestaurantList(
        position: LatLng(widget.location.latitude, widget.location.longitude),
      ),
    ];
    _loadWeatherData(widget.location);
  }

  Widget buildWidget(int _selectedIndex) {
    return _widgetOptions[_selectedIndex];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
          backgroundColor: Colors.grey[300],
          body: Center(child: CircularProgressIndicator()));
    }
    final weatherData = _weatherData;
    var temperature = weatherData['main']['temp'] - 273;
    temperature = double.parse(temperature.toStringAsFixed(1));
    final condition = weatherData['weather'][0]['description'].toString();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/CHATBOT");
        },
        child: Icon(Icons.support_agent),
        backgroundColor: Colors.blue[800],
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text(
          widget.cityName,
          style: GoogleFonts.chivo(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          //Image.network(widget.imageUrl),
          Padding(
            padding: const EdgeInsets.fromLTRB(11.0, 8, 11, 0),
            child: Container(
              color: Colors.blue,
              child: Column(
                children: [
                  SizedBox(
                    height: 5,
                  ),
                  // Text(widget.cityName),
                  /*Text(
                      "Location: ${widget.location.latitude}, ${widget.location.longitude}"),*/
                  Text(
                    "$temperature C | $condition",
                    style: GoogleFonts.chivo(
                      color: Colors.white,
                    ),
                  ),
                  // Text(condition),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          ),
          Divider(
            thickness: 2,
            color: Colors.blue[800],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              11,
              0,
              11,
              0,
            ),
            child: Container(
              height: 222,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  zoom: 14.0,
                  target: LatLng(
                      widget.location.latitude, widget.location.longitude),
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('marker'),
                    position: _markerLocation,
                    draggable: true,
                    onDragEnd: _onMarkerDragEnd,
                  ),
                },
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
                onTap: _onMapTapped,
              ),
            ),
          ),
          Divider(
            thickness: 2,
            color: Colors.blue[800],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
                child: Text(
                  'Hotels',
                  style: TextStyle(
                    fontWeight: _selectedIndex == 0
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
                child: Text(
                  'Museums',
                  style: TextStyle(
                    fontWeight: _selectedIndex == 1
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                  print(_selectedIndex);
                },
                child: Text(
                  'Restaurants',
                  style: TextStyle(
                    fontWeight: _selectedIndex == 2
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
          buildWidget(_selectedIndex)
        ],
      ),
    );
  }

  void _onMarkerDragEnd(LatLng position) {
    setState(() {
      _markerLocation = position;
    });
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _markerLocation = position;
    });
    _controller.animateCamera(CameraUpdate.newLatLng(position));
  }
}
