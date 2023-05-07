import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanderlust/CHATBOT/Chat_bot.dart';
import 'package:wanderlust/CHATBOT/screens/chat_screen.dart';
import 'package:wanderlust/CountryCarousel.dart';
import 'package:wanderlust/EventFinder.dart';
import 'package:wanderlust/Firebasedemo.dart';
import 'package:wanderlust/Geocoding/GetLocation.dart';
import 'package:wanderlust/createform.dart';
import 'package:wanderlust/deneme.dart';
import 'package:wanderlust/editprofilepage.dart';
import 'package:wanderlust/emailverification.dart';
import 'package:wanderlust/event.dart';
import 'package:wanderlust/fill-infos-off-new-account.dart';
import 'package:wanderlust/location.dart';
import 'package:wanderlust/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderlust/profilepage.dart';
import 'package:wanderlust/weather.dart';
import 'package:wanderlust/signupdocs/signup.dart';
import 'package:wanderlust/signupdocs/login.dart';
import 'package:wanderlust/signupdocs/services/auh.dart';

class MyApp extends StatefulWidget {
  static String name = "A";

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> buildData() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('Person').doc(userId);
    DocumentSnapshot snapshot = await userRef.get();
    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
    MyApp.name = userData['name'] ?? '';
  }

  @override
  void initState() {
    super.initState();
    buildData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            buildData();
            if (snapshot.hasData) {
              if (FirebaseAuth.instance.currentUser!.emailVerified) {
                if (MyApp.name.isEmpty) {
                  return FillName();
                } else {
                  return MainPage();
                }
              } else {
                return EmailVerify();
              }
            } else {
              return LoginScreen();
            }
          },
        ),
      ),
      routes: {
        '/signup': (context) {
          return SignUpScreen();
        },
        '/login': (context) {
          return LoginScreen();
        },
        '/passwordreset': (context) {
          return passwordResetPage();
        },
        '/profile': (context) {
          return ProfilePage();
        },
        '/mainpage': (context) {
          return MainPage();
        },
        '/findlocation': (context) {
          return findLocation();
        },
        '/weathershow': (context) {
          return ShowWeather();
        },
        '/editprofile': (context) {
          return EditUsersProfilePage();
        },
        '/form': (context) {
          return TravelGuideApp();
        },
        '/fillname': (context) {
          return FillName();
        },
        '/emailverify': (context) {
          return EmailVerify();
        },
        '/myapp': (context) {
          return MyApp();
        },
        '/viewallcountry': (context) {
          return CountryCarousel();
        },
        '/CHATBOT': (context) {
          return CHATBOT();
        },
        '/searchbar': (context) {
          return SearchBar();
        }
      },
    );
  }
}
