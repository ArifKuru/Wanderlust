import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:wanderlust/signupdocs/services/auh.dart';

class FillName extends StatefulWidget {
  const FillName({Key? key}) : super(key: key);

  @override
  State<FillName> createState() => _FillNameState();
}

class _FillNameState extends State<FillName> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthService _authService = AuthService();

  TextEditingController name = TextEditingController();
  TextEditingController surname = TextEditingController();
  TextEditingController nickname = TextEditingController();

  TextEditingController phone = TextEditingController();
  String selectedCountry = "CHOOSE COUNTRY";
  DateTime dateTime = DateTime.now();
  bool dateChanged = false;
  bool error = false;
  int checkEmpty(String name, String surname, String nickname, String phone,
      String selectedCountry, DateTime dateTime) {
    if (name.isEmpty ||
        surname.isEmpty ||
        nickname.isEmpty ||
        phone.isEmpty ||
        selectedCountry == "CHOOSE COUNTRY" ||
        dateChanged == false) {
      return 1;
    } else {
      return 0;
    }
  }

  void updateUserProfile(String name, String surname, String nickname,
      String Phone, String country, DateTime dateTime) async {
    // Get the current user's ID
    String userId = _auth.currentUser!.uid;

    // Get a reference to the user document in Firestore
    DocumentReference userRef = _firestore.collection('Person').doc(userId);

    // Update the user document with the new data
    await userRef.set({
      'name': name,
      'surname': surname,
      'nickname': nickname,
      'phone': Phone,
      'birthdate': dateTime,
      'country': country,
    }, SetOptions(merge: true));
  }

  final List<String> countries = [
    'CHOOSE COUNTRY',
    'Australia',
    'Brazil',
    'Canada',
    'China',
    'France',
    'Germany',
    'Greece',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Israel',
    'Italy',
    'Japan',
    'Mexico',
    'Netherlands',
    'New Zealand',
    'Nigeria',
    'Pakistan',
    'Philippines',
    'Poland',
    'Russia',
    'Saudi Arabia',
    'South Africa',
    'South Korea',
    'Spain',
    'Sweden',
    'Switzerland',
    'Taiwan',
    'Thailand',
    'Turkey',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Vietnam',
    'Egypt',
    'Morocco',
    'Argentina',
    'Colombia'
  ];

  void _showDatepicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1923),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        dateTime = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: ListView(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 5,
                ),
                TextButton(
                  onPressed: () {
                    _auth.signOut();
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                  child: Container(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.exit_to_app_outlined,
                          size: 15,
                          color: Colors.orange,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Logout & Continue later",
                          style: GoogleFonts.chivo(color: Colors.black38),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Icon(
              Icons.account_box_outlined,
              color: Colors.blue[800],
              size: 60,
            ),
            SizedBox(
              height: 15,
            ),
            Center(
              child: Text(
                "\"Let's learn\"",
                style: GoogleFonts.robotoMono(fontSize: 25, color: Colors.blue),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Center(
              child: Text(
                "\"more about you\"",
                style: GoogleFonts.robotoMono(fontSize: 25, color: Colors.blue),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                SizedBox(width: 55),
                Text("Name"),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Expanded(
                child: TextField(
                  controller: nickname,
                  decoration: InputDecoration(
                    hintText: "Type your nickname here !",
                    // hintStyle: TextStyle(color: Colors.blue),
                    prefixIcon: Icon(
                      Icons.account_circle,
                      color: Colors.blue,
                    ),
                    border: OutlineInputBorder(
                        //borderSide: BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: 30,
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: name,
                          decoration: InputDecoration(
                            hintText: "Name",
                            // hintStyle: TextStyle(color: Colors.blue),
                            prefixIcon: Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                            border: OutlineInputBorder(
                                //borderSide: BorderSide(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: TextField(
                          controller: surname,
                          decoration: InputDecoration(
                            hintText: "Surname",
                            // hintStyle: TextStyle(color: Colors.blue),
                            prefixIcon: Icon(
                              Icons.abc,
                              color: Colors.blue,
                            ),
                            border: OutlineInputBorder(
                                //borderSide: BorderSide(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(width: 55),
                Text("Phone"),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                SizedBox(
                  width: 30,
                ),
                Expanded(
                  child: IntlPhoneField(
                    controller: phone,
                    decoration: InputDecoration(
                      hintText: "Type your phone here !",
                      // hintStyle: TextStyle(color: Colors.blue),
                      prefixIcon: Icon(
                        Icons.phone,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                          //borderSide: BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(width: 55),
                Text("Birth day"),
              ],
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  dateChanged = true;
                  _showDatepicker();
                });
              },
              child: Container(
                height: 45,
                width: 350,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.orange),
                //color: Colors.black,
                child: Center(
                  child: myTime(dateChanged, dateTime),
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(width: 55),
                Text("Country"),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                SizedBox(
                  width: 30,
                ),
                Container(
                  height: 45,
                  width: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.orange,
                  ),
                  child: Center(
                    child: DropdownButton<String>(
                      value: selectedCountry,
                      style: GoogleFonts.changaOne(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      dropdownColor: Colors.black12,
                      alignment: Alignment.center,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedCountry = newValue!;
                        });
                      },
                      items: countries
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Error(error),
            TextButton(
              onPressed: () {
                if (checkEmpty(name.text, surname.text, nickname.text,
                        phone.text, selectedCountry.toString(), dateTime) ==
                    1) {
                  setState(() {
                    error = true;
                  });
                } else {
                  updateUserProfile(name.text, surname.text, nickname.text,
                      phone.text, selectedCountry.toString(), dateTime);
                  Navigator.pushReplacementNamed(context, "/mainpage");
                }
              },
              child: Container(
                height: 45,
                width: 350,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue[800]),
                //color: Colors.black,
                child: Center(
                  child: Text(
                    "COMPLETE THE REGISTRATION",
                    style: GoogleFonts.changaOne(
                        color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget myTime(bool dateChanged, DateTime dateTime) {
    if (dateChanged == false) {
      return Text("SET BIRTH DAY",
          style: GoogleFonts.changaOne(color: Colors.white, fontSize: 18));
    } else {
      return Text("${dateTime.day}/${dateTime.month}/${dateTime.year}",
          style: GoogleFonts.changaOne(color: Colors.white, fontSize: 18));
    }
  }

  Widget Error(bool error) {
    if (error == false) {
      return SizedBox(
        height: 15,
      );
    } else {
      return Container(
        height: 15,
        child: Center(
          child: Text(
            "Blanks must be filled",
            style: GoogleFonts.chivo(
              color: Colors.red,
            ),
          ),
        ),
      );
    }
  }
}
