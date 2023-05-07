import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void dispose() {
    super.dispose();
  }

  String email = FirebaseAuth.instance.currentUser!.email.toString();
  String uid = FirebaseAuth.instance.currentUser!.uid.toString();
  final _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Widget buildData(
      BuildContext context, String datatype, Color _color, double size) {
    String userId = _auth.currentUser!.uid;
    DocumentReference userRef = _firestore.collection('Person').doc(userId);
    return StreamBuilder<DocumentSnapshot>(
      stream: userRef.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading...');
        }

        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>;

        dynamic x;

        switch (datatype) {
          case "name":
            x = userData['name'];
            break;
          case "phone":
            x = userData['phone'];
            break;
          case "about":
            x = userData['about'];
            break;
          case "nickname":
            x = userData['nickname'];
            break;
          case "birthdate":
            x = (userData['birthdate'] as Timestamp).toDate();
            var year = x.year.toString();
            var _month = x.month.toString();
            switch (_month) {
              case "1":
                _month = "January";
                break;
              case "2":
                _month = "February";
                break;
              case "3":
                _month = "March";
                break;
              case "4":
                _month = "April";
                break;
              case "5":
                _month = "May";
                break;
              case "6":
                _month = "June";
                break;
              case "7":
                _month = "July ";
                break;
              case "8":
                _month = "August";
                break;
              case "9":
                _month = "September";
                break;
              case "10":
                _month = "October";
                break;
              case "11":
                _month = "November";
                break;
              case "12":
                _month = "December";
                break;
            }
            ;
            var day = x.day.toString();
            return Text(
              " $day $_month $year ",
              style: GoogleFonts.robotoMono(
                color: _color,
                fontSize: size,
              ),
            );
            break;
          case "country":
            x = userData['country'];
        }

        return Text(
          x,
          style: GoogleFonts.robotoMono(
            color: _color,
            fontSize: size,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [
      Row(
        children: [
          SizedBox(
            width: 15,
          ),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 40,
                      ),
                      Text(
                        "About me",
                        style: GoogleFonts.robotoMono(
                            fontSize: 20, color: Colors.blue[800]),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: 300,
                    child: buildData(context, "about", Colors.black38, 17),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 15,
          ),
        ],
      ),
      Row(
        children: [
          SizedBox(width: 30),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Text(
                        "Primary informations",
                        style: GoogleFonts.chivo(
                            fontSize: 20, color: Colors.blue[800]),
                      ),
                    ],
                  ),
                  Container(
                    width: 300,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              "From : ",
                              style: GoogleFonts.chivo(color: Colors.orange),
                            ),
                            buildData(context, "country", Colors.black38, 17),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Name : ",
                              style: GoogleFonts.chivo(color: Colors.orange),
                            ),
                            buildData(context, "name", Colors.black38, 17),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Born in : ",
                              style: GoogleFonts.chivo(color: Colors.orange),
                            ),
                            buildData(context, "birthdate", Colors.black38, 17),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 30),
        ],
      ),
      Row(
        children: [
          SizedBox(width: 30),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Text(
                        "Contact informations",
                        style: GoogleFonts.chivo(
                            fontSize: 20, color: Colors.blue[800]),
                      ),
                    ],
                  ),
                  Container(
                    width: 300,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Phone number : ",
                              style: GoogleFonts.chivo(color: Colors.orange),
                            ),
                            buildData(context, "phone", Colors.black38, 17),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Email : ",
                              style: GoogleFonts.chivo(color: Colors.orange),
                            ),
                            Text(
                              email,
                              style: GoogleFonts.robotoMono(
                                  color: Colors.black38, fontSize: 17),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 30),
        ],
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Container(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/mainpage');
                                },
                                child: Icon(
                                  Icons.arrow_back_ios_new_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 100.0),
                              child: StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Person')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }

                                  final data = snapshot.data?.data()
                                      as Map<String, dynamic>?;

                                  final String downloadUrl =
                                      data?['ppUrl'] ?? null;

                                  return CircleAvatar(
                                    radius: 50,
                                    backgroundImage: downloadUrl != null
                                        ? Image.network(
                                            downloadUrl,
                                            fit: BoxFit.cover,
                                          ).image
                                        : null,
                                    child: downloadUrl == null
                                        ? Icon(Icons.person, size: 50)
                                        : null,
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  FirebaseAuth.instance.signOut().then(
                                      (value) => Navigator.pushNamed(
                                          context, "/login"));
                                },
                                child: Center(
                                  child: Icon(
                                    Icons.exit_to_app_outlined,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        buildData(context, "nickname", Colors.white, 25),
                        //buildData(context, "name", Colors.white, 25),
                        SizedBox(
                          height: 19,
                        ),
                        Row(
                          //      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 83,
                            ),
                            Text(
                              "0",
                              style: GoogleFonts.changaOne(
                                  color: Colors.white, fontSize: 20),
                            ),
                            SizedBox(
                              width: 109,
                            ),
                            Text(
                              "0",
                              style: GoogleFonts.changaOne(
                                  color: Colors.white, fontSize: 20),
                            ),
                            SizedBox(
                              width: 108,
                            ),
                            Text(
                              "0",
                              style: GoogleFonts.changaOne(
                                  color: Colors.white, fontSize: 20),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Friends",
                              style: GoogleFonts.chivo(color: Colors.white),
                            ),
                            Text(
                              "Comments",
                              style: GoogleFonts.chivo(color: Colors.white),
                            ),
                            Text(
                              "Posts",
                              style: GoogleFonts.chivo(color: Colors.white),
                            ),
                          ],
                        ),
                        /*Text(
                          email,
                          style: GoogleFonts.robotoMono(
                              color: Colors.white, fontSize: 15),
                        ),*/
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/editprofile');
                              },
                              child: Container(
                                width: 140,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.blue[800],
                                    borderRadius: BorderRadius.circular(100)),
                                child: Center(
                                    child: Text(
                                  "EDIT PROFILE",
                                  style: GoogleFonts.robotoMono(
                                    color: Colors.white,
                                  ),
                                )),
                              ),
                            ),
                            SizedBox(
                              width: 0,
                            ),
                            Container(
                              width: 60,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.grey[600],
                                  borderRadius: BorderRadius.circular(100)),
                              child: Center(
                                child: Icon(
                                  Icons.map_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 60,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.grey[600],
                                  borderRadius: BorderRadius.circular(100)),
                              child: Center(
                                child: Icon(
                                  Icons.email,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      alignment: Alignment.topCenter,
                      image: AssetImage("assets/images/ppbg1.jfif"),
                    ))),
              ],
            ),
            CarouselSlider(
              // Set carousel options
              options: CarouselOptions(
                // height: 400, // Set carousel height
                enlargeCenterPage: false, // Enlarge center item
                enableInfiniteScroll: true, // Allow infinite scroll
                initialPage: 0, // Set initial page to show
                viewportFraction: 1, // Show full item on screen
              ),
              // Map through list of rows to create items
              items: rows.map(
                (row) {
                  // Use LayoutBuilder to get size constraints
                  return LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      // Use SizedBox to set item size and add content
                      return SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: row,
                      );
                    },
                  );
                },
              ).toList(),
            ),
            Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      "Travel history",
                      style: GoogleFonts.changaOne(),
                    ),
                    SizedBox(
                      width: 200,
                    ),
                    Text(
                      "View details",
                      style: GoogleFonts.changaOne(color: Colors.orange),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            width: 120,
                            height: 120,
                            child: Image.asset(
                              "assets/images/cityimages/london.jpg",
                              fit: BoxFit.cover,
                            )),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            width: 120,
                            height: 120,
                            child: Image.asset(
                              "assets/images/cityimages/tokyo.jpg",
                              fit: BoxFit.cover,
                            )),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            width: 120,
                            height: 120,
                            child: Image.asset(
                              "assets/images/cityimages/newyork.webp",
                              fit: BoxFit.cover,
                            )),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
