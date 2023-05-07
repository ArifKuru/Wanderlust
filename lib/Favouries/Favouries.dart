import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wanderlust/CityPage.dart';

import '../main.dart';

class Favouries extends StatefulWidget {
  const Favouries({Key? key}) : super(key: key);

  @override
  State<Favouries> createState() => _FavouriesState();
}

class _FavouriesState extends State<Favouries> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              "You can see here your favouries that you selected",
              style: GoogleFonts.chivo(color: Colors.blue[800]),
            ),
          ),
          Icon(
            Icons.favorite,
            color: Colors.blue[800],
            size: 100,
          ),
          Row(
            children: [
              SizedBox(
                width: 15,
              ),
              Text(
                "Your favorite countries",
                style: GoogleFonts.chivo(color: Colors.blue[800]),
              ),
            ],
          ),
          FavCountriesCarousel(uid: FirebaseAuth.instance.currentUser!.uid),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              SizedBox(
                width: 15,
              ),
              Text(
                "Your favorite cities",
                style: GoogleFonts.chivo(color: Colors.blue[800]),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          FavCitiesCarousel(uid: FirebaseAuth.instance.currentUser!.uid),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              SizedBox(
                width: 15,
              ),
              Text(
                "Your favorite attractions",
                style: GoogleFonts.chivo(color: Colors.blue[800]),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

class FavCountriesCarousel extends StatelessWidget {
  final String uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FavCountriesCarousel({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Person')
          .doc(uid)
          .collection('FavCountries')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else {
          final countries = snapshot.data!.docs;
          return SizedBox(
            height: 120.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index].data() as Map<String, dynamic>;
                final imageUrl = country['image'] ?? '';
                final name = country['name'] ?? '';
                final shortCut = country["shortcut"] ?? '';
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CityScreen(city: shortCut),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 40.0,
                          backgroundImage: NetworkImage(imageUrl),
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(name),
                    ],
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}

class FavCitiesCarousel extends StatelessWidget {
  final String uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FavCitiesCarousel({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Person')
          .doc(uid)
          .collection('FavCities')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        } else {
          final countries = snapshot.data!.docs;
          return SizedBox(
            height: 120.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index].data() as Map<String, dynamic>;
                final imageUrl = country['image'] ?? '';
                final name = country['name'] ?? '';
                final location = country["location"] ?? "";
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CityDetailPage(
                                cityName: name,
                                imageUrl: imageUrl,
                                location: location,
                              ),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 40.0,
                          backgroundImage: NetworkImage(imageUrl),
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(name),
                    ],
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
