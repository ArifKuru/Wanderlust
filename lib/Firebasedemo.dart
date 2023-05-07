import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class TrapAdvisorHotels extends StatefulWidget {
  final LatLng latLng;

  TrapAdvisorHotels({required this.latLng});

  @override
  _TrapAdvisorHotelsState createState() => _TrapAdvisorHotelsState();
}

class _TrapAdvisorHotelsState extends State<TrapAdvisorHotels> {
  final String apiKey = "*";
  final int radius = 5000; // Search radius in meters
  bool _isLoading = true;
  List<dynamic>? hotels;

  @override
  void initState() {
    super.initState();
    _fetchHotels();
  }

  Future<void> _fetchHotels() async {
    String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${widget.latLng.latitude},${widget.latLng.longitude}&radius=${radius}&type=lodging&key=${apiKey}";

    var response = await http.get(Uri.parse(url));
    var data = json.decode(response.body);

    setState(() {
      hotels = data["results"];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CircularProgressIndicator();
    } else {
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: hotels?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            var hotel = hotels?[index];
            if (hotel?["photos"]?[0]?["photo_reference"] == null) {
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HotelDetailsPage(hotel: hotel),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${hotel?["photos"]?[0]?["photo_reference"]}&key=${apiKey}",
                        ),
                      ),
                    ),
                    Container(
                      height: 100,
                      width: 100,
                      child: Text(
                        hotel?["name"] ?? "",
                        style: GoogleFonts.chivo(
                          color: Colors.black38,
                          fontSize: 14.0,
                        ),
                      ),
                      /*Text(
                          hotel?["vicinity"] ?? "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                          ),
                        ),*/
                    ),
                  ],
                ),
              );
            }
          },
        ),
      );
    }
  }
}

class HotelDetailsPage extends StatelessWidget {
  final Map<String, dynamic>? hotel;
  final String apiKey = "*";
  HotelDetailsPage({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text(hotel?["name"] ?? ""),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                height: 240,
                width: 390,
                child: Image.network(
                  "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${hotel?["photos"]?[0]?["photo_reference"]}&key=${apiKey}",
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                hotel?["name"] ?? "",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Address: ${hotel?["vicinity"] ?? "-"}",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Location: ${hotel?["geometry"]?["location"]?["lat"]?.toStringAsFixed(6)}, ${hotel?["geometry"]?["location"]?["lng"]?.toStringAsFixed(6)}",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            /* Text(
              "Otelin Yer İşareti: ${hotel?["place_id"] ?? "-"}",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),*/
            Text(
              "Rating: ${hotel?["rating"] ?? "-"}",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Ratings total: ${hotel?["user_ratings_total"] ?? "-"}",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Phone number: ${hotel?["formatted_phone_number"] ?? "-"}",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                if (hotel?["website"] != null) {
                  launch(hotel?["website"]);
                }
              },
              child: Text(
                "Web site: ${hotel?["website"] ?? "-"}",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            RatingWidget(
              HotelName: hotel?["name"],
            ),
          ],
        ),
      ),
    );
  }
}

class RatingWidget extends StatefulWidget {
  final Function(int)? onRated;
  final String HotelName;
  RatingWidget({required this.HotelName, this.onRated});

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  int _rating = 0;

  void _setRating(int rating) {
    setState(() {
      _rating = rating;
    });
    widget.onRated?.call(rating);
  }

  Future<void> addRating(String hotelId, String userId, double rating) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final hotelsCollectionRef = firestore.collection("Hotels");
      final ratingsCollectionRef =
          hotelsCollectionRef.doc(hotelId).collection("ratings");

      final userDocRef = ratingsCollectionRef.doc(userId);
      await userDocRef.set({"rating": rating});

      print("Rating added successfully");
    } catch (e) {
      print("Error adding rating: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(_rating >= 1 ? Icons.star : Icons.star_border),
          color: _rating >= 1 ? Colors.orange : null,
          onPressed: () => _setRating(1),
        ),
        IconButton(
          icon: Icon(_rating >= 2 ? Icons.star : Icons.star_border),
          color: _rating >= 2 ? Colors.orange : null,
          onPressed: () => _setRating(2),
        ),
        IconButton(
          icon: Icon(_rating >= 3 ? Icons.star : Icons.star_border),
          color: _rating >= 3 ? Colors.orange : null,
          onPressed: () => _setRating(3),
        ),
        IconButton(
          icon: Icon(_rating >= 4 ? Icons.star : Icons.star_border),
          color: _rating >= 4 ? Colors.orange : null,
          onPressed: () => _setRating(4),
        ),
        IconButton(
          icon: Icon(_rating >= 5 ? Icons.star : Icons.star_border),
          color: _rating >= 5 ? Colors.orange : null,
          onPressed: () => _setRating(5),
        ),
      ],
    );
  }
}

class TrapAdvisorMuseums extends StatefulWidget {
  final LatLng latLng;
  TrapAdvisorMuseums({required this.latLng});

  @override
  _TrapAdvisorMuseumsState createState() => _TrapAdvisorMuseumsState();
}

class _TrapAdvisorMuseumsState extends State<TrapAdvisorMuseums> {
  final String apiKey = "*";
  final int radius = 5000; // Search radius in meters
  bool _isLoading = true;
  List<dynamic>? museums;

  @override
  void initState() {
    super.initState();
    _fetchMuseums();
  }

  Future<void> _fetchMuseums() async {
    final String apiKey = "*";
    final int radius = 5000; // Search radius in meters
    String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${widget.latLng.latitude},${widget.latLng.longitude}&radius=${radius}&type=museum&key=${apiKey}";

    var response = await http.get(Uri.parse(url));
    var data = json.decode(response.body);

    setState(() {
      museums = data["results"];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CircularProgressIndicator();
    } else {
      return SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: museums?.length ?? 0,
          itemBuilder: (BuildContext context, int index) {
            var hotel = museums?[index];
            if (hotel?["photos"]?[0]?["photo_reference"] == null) {
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HotelDetailsPage(hotel: hotel),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${hotel?["photos"]?[0]?["photo_reference"]}&key=${apiKey}",
                        ),
                      ),
                    ),
                    Container(
                      height: 100,
                      width: 100,
                      child: Text(
                        hotel?["name"] ?? "",
                        style: GoogleFonts.chivo(
                          color: Colors.black38,
                          fontSize: 14.0,
                        ),
                      ),
                      /*Text(
                          hotel?["vicinity"] ?? "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                          ),
                        ),*/
                    ),
                  ],
                ),
              );
            }
          },
        ),
      );
    }
  }
}
