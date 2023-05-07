import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShowWeather extends StatefulWidget {
  @override
  _ShowWeatherState createState() => _ShowWeatherState();
}

class _ShowWeatherState extends State<ShowWeather> {
  bool _isLoading = false;
  dynamic _weatherData;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? CircularProgressIndicator()
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "Weather Information of your Favourite Cities ! ",
                    style: GoogleFonts.chivo(color: Colors.blue[800]),
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("Person")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection("FavCities")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    return Container(
                      height: snapshot.data!.docs.length * 71,
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          final city = snapshot.data!.docs[index];
                          final cityName = city["name"];
                          final cityLocation = city["location"] as GeoPoint;
                          return ListTile(
                            title: Text(
                              cityName,
                              style: GoogleFonts.chivo(color: Colors.blue[800]),
                            ),
                            subtitle: FutureBuilder<dynamic>(
                              future: _getWeatherData(cityLocation),
                              builder: (BuildContext context,
                                  AsyncSnapshot<dynamic> snapshot) {
                                if (snapshot.hasData) {
                                  final weatherData = snapshot.data;
                                  final condition = weatherData['weather'][0]
                                          ['description']
                                      .toString();
                                  final temperature =
                                      (weatherData["main"]["temp"] - 273.15)
                                          .toStringAsFixed(1);
                                  return Text('$temperature °C | $condition');
                                } else if (snapshot.hasError) {
                                  return Text('Error loading weather data');
                                } else {
                                  return CircularProgressIndicator();
                                }
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Future<dynamic> _getWeatherData(GeoPoint location) async {
    final String apiKey = '*';
    final String apiUrl = 'https://api.openweathermap.org/data/2.5/weather';

    final url =
        '$apiUrl?lat=${location.latitude}&lon=${location.longitude}&appid=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      return decodedData;
    } else {
      throw Exception('Error fetching weather data: ${response.statusCode}');
    }
  }
}
