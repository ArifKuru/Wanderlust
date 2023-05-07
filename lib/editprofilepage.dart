import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class EditUsersProfilePage extends StatefulWidget {
  const EditUsersProfilePage({Key? key}) : super(key: key);

  @override
  State<EditUsersProfilePage> createState() => _EditUsersProfilePageState();
}

class _EditUsersProfilePageState extends State<EditUsersProfilePage> {
  XFile? image;
  String downloadLink = "";
  Widget ifEmpty(bool _isEmpty) {
    if (_isEmpty) {
      return Text(
        "Blanks must be filled",
        style: GoogleFonts.chivo(
          color: Colors.red,
        ),
      );
    } else {
      return SizedBox(
        height: 20,
      );
    }
  }

  @override
  final ImagePicker picker = ImagePicker();

  //we can upload image from camera or from gallery based on parameter
  Future<void> getImage(ImageSource media) async {
    final pickedFile = await ImagePicker().getImage(source: media);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);

      final Reference reference = FirebaseStorage.instance
          .ref()
          .child('Profilephotos')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('profilephoto.png');

      final UploadTask uploadTask = reference.putFile(file);
      final TaskSnapshot downloadUrlTask =
          await uploadTask.whenComplete(() => null);

      final String downloadUrl = await downloadUrlTask.ref.getDownloadURL();

      updateUserProfile(downloadUrl, 'ppUrl');
    }
  }

  //show popup dialog
  void myAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Please choose media to select'),
            content: Container(
              height: MediaQuery.of(context).size.height / 6,
              child: Column(
                children: [
                  ElevatedButton(
                    //if user click this button, user can upload image from gallery
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.gallery);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.image),
                        Text('From Gallery'),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    //if user click this button. user can upload image from camera
                    onPressed: () {
                      Navigator.pop(context);
                      getImage(ImageSource.camera);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.camera),
                        Text('From Camera'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String email = FirebaseAuth.instance.currentUser!.email.toString();

  final List<String> countries = [
    'Select country',
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

  String selectedCountry = 'Select country';

  DateTime dateTime = DateTime.now();

  void sendResetPassword() {
    User? user = _auth.currentUser;
    _auth.sendPasswordResetEmail(email: user!.email.toString());
  }

  Widget buildData(
      BuildContext context, String datatype, Color _color, double size) {
    String userId = _auth.currentUser!.uid;
    var _month;
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
          case "nickname":
            x = userData['nickname'];
            break;
          case "name":
            x = userData['name'];
            break;
          case "phone":
            x = userData['phone'];
            break;
          case "about":
            x = userData['about'];
            break;
          case "birthdate":
            x = (userData['birthdate'] as Timestamp).toDate();
            var year = x.year.toString();
            var month = x.month.toString();
            switch (month) {
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
            var day = x.day.toString();
            return Text(
              " $day $_month $year ",
              style: GoogleFonts.robotoMono(
                color: _color,
                fontSize: size,
              ),
            );
          case "country":
            x = userData['country'];
            break;
          case "surname":
            x = userData['surname'];
            break;
        }

        return Text(
          " $x ",
          style: GoogleFonts.robotoMono(
            color: _color,
            fontSize: size,
          ),
        );
      },
    );
  }

  void _showDatepicker() {
    final now = DateTime.now();
    final initialDate = DateTime(now.year - 18, now.month, now.day);
    final lastDate = DateTime(now.year - 18, now.month, now.day);

    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1923),
      lastDate: lastDate,
    ).then((value) {
      if (value != null) {
        setState(() {
          dateTime = value;
          updateUserProfile(dateTime, "birthdate");
        });
      }
    });
  }

  void updateUserProfile(dynamic NewValue, String FieldName) async {
    // Get the current user's ID
    String userId = _auth.currentUser!.uid;

    // Get a reference to the user document in Firestore
    DocumentReference userRef = _firestore.collection('Person').doc(userId);

    // Update the user document with the new data
    await userRef.set({
      FieldName: NewValue,
    }, SetOptions(merge: true));
  }

  void sendVerification() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[300],
            title: Text(
              "Do you want to receive Reset password email",
              style: GoogleFonts.chivo(color: Colors.blue[800]),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("No")),
                  ),
                  Expanded(
                    child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          sendResetPassword();
                        },
                        child: Text("Yes")),
                  ),
                ],
              )
            ],
          );
        });
  }

  void EditName() {
    TextEditingController NewValue = TextEditingController();
    TextEditingController NewValue2 = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[300],
            title: Text(
              "Change Name surname",
              style: GoogleFonts.chivo(color: Colors.blue[800]),
            ),
            actions: [
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: NewValue,
                          decoration: InputDecoration(
                            labelText: "Name",
                            hintText: "",
                            // hintStyle: TextStyle(color: Colors.blue),
                            prefixIcon: Icon(
                              Icons.account_box_outlined,
                              color: Colors.blue,
                            ),
                            border: OutlineInputBorder(
                                //borderSide: BorderSide(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(0)),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: TextField(
                          controller: NewValue2,
                          decoration: InputDecoration(
                            labelText: "Surname",
                            hintText: "",
                            // hintStyle: TextStyle(color: Colors.blue),

                            border: OutlineInputBorder(
                                //borderSide: BorderSide(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 120,
                            height: 25,
                            child: Center(
                              child: Text(
                                "CANCEL",
                                style: GoogleFonts.changaOne(
                                  color: Colors.red[800],
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            if (NewValue.text.isEmpty &&
                                NewValue2.text.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.grey[300],
                                    content: Text(
                                      "Please fill the blank",
                                      style:
                                          GoogleFonts.chivo(color: Colors.red),
                                    ),
                                  );
                                },
                              );
                            } else {
                              Navigator.pop(context);
                              if (NewValue2.text.isEmpty) {
                                updateUserProfile(NewValue.text, "name");
                              } else if (NewValue.text.isEmpty) {
                                updateUserProfile(NewValue2.text, "surname");
                              } else {
                                updateUserProfile(NewValue2.text, "surname");
                                updateUserProfile(NewValue.text, "name");
                              }
                            }
                          },
                          child: Container(
                            width: 120,
                            height: 25,
                            child: Center(
                              child: Text(
                                "SAVE",
                                style: GoogleFonts.changaOne(
                                  color: Colors.blue[800],
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  )
                ],
              ),
            ],
          );
        });
  }

  void EditPhone() {
    TextEditingController NewValue = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[300],
            title: Text(
              "Change Phone number",
              style: GoogleFonts.chivo(color: Colors.blue[800]),
            ),
            actions: [
              Column(
                children: [
                  IntlPhoneField(
                    controller: NewValue,
                    decoration: InputDecoration(
                      labelText: "New Phone number",
                      hintText: "",
                      // hintStyle: TextStyle(color: Colors.blue),
                      prefixIcon: Icon(
                        Icons.account_box_outlined,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                          //borderSide: BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 120,
                            height: 25,
                            child: Center(
                              child: Text(
                                "CANCEL",
                                style: GoogleFonts.changaOne(
                                  color: Colors.red[800],
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            if (NewValue.text.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.grey[300],
                                    content: Text(
                                      "Please fill the blank",
                                      style:
                                          GoogleFonts.chivo(color: Colors.red),
                                    ),
                                  );
                                },
                              );
                            } else {
                              Navigator.pop(context);
                              updateUserProfile(NewValue.text, "phone");
                            }
                          },
                          child: Container(
                            width: 120,
                            height: 25,
                            child: Center(
                              child: Text(
                                "SAVE",
                                style: GoogleFonts.changaOne(
                                  color: Colors.blue[800],
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        });
  }

  void EditInfo(String FieldName) {
    TextEditingController NewValue = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[300],
            title: Text(
              "Change $FieldName",
              style: GoogleFonts.chivo(color: Colors.blue[800]),
            ),
            actions: [
              Column(
                children: [
                  TextField(
                    controller: NewValue,
                    decoration: InputDecoration(
                      labelText: "New $FieldName",
                      hintText: "",
                      // hintStyle: TextStyle(color: Colors.blue),
                      prefixIcon: Icon(
                        Icons.account_box_outlined,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                          //borderSide: BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 120,
                            height: 25,
                            child: Center(
                              child: Text(
                                "CANCEL",
                                style: GoogleFonts.changaOne(
                                  color: Colors.red[800],
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            if (NewValue.text.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.grey[300],
                                    content: Text(
                                      "Please fill the blank",
                                      style:
                                          GoogleFonts.chivo(color: Colors.red),
                                    ),
                                  );
                                },
                              );
                            } else {
                              Navigator.pop(context);
                              updateUserProfile(NewValue.text, FieldName);
                            }
                          },
                          child: Container(
                            width: 120,
                            height: 25,
                            child: Center(
                              child: Text(
                                "SAVE",
                                style: GoogleFonts.changaOne(
                                  color: Colors.blue[800],
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        });
  }

  void EditCountry() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[300],
          title: Text(
            "Change country",
            style: GoogleFonts.chivo(color: Colors.blue[800]),
          ),
          actions: [
            Center(
              child: DropdownButton<String>(
                value: selectedCountry,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCountry = newValue!;
                  });
                },
                items: countries.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                    enabled: true,
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 120,
                      height: 25,
                      child: Center(
                        child: Text(
                          "CANCEL",
                          style: GoogleFonts.changaOne(
                            color: Colors.red[800],
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      if (selectedCountry.toString() == "Select country") {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.grey[300],
                              content: Text(
                                "Please select a country",
                                style: GoogleFonts.chivo(color: Colors.red),
                              ),
                            );
                          },
                        );
                      } else {
                        Navigator.pop(context);
                        updateUserProfile(selectedCountry, "country");
                      }
                    },
                    child: Container(
                      width: 120,
                      height: 25,
                      child: Center(
                        child: Text(
                          "SAVE",
                          style: GoogleFonts.changaOne(
                            color: Colors.blue[800],
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void EditAbout() {
    TextEditingController NewValue = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[300],
            title: Text(
              "Change about me text",
              style: GoogleFonts.chivo(color: Colors.blue[800]),
            ),
            actions: [
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "About me",
                        style: GoogleFonts.chivo(color: Colors.black38),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextField(
                    maxLines: 5,
                    controller: NewValue,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 120,
                            height: 25,
                            child: Center(
                              child: Text(
                                "CANCEL",
                                style: GoogleFonts.changaOne(
                                  color: Colors.red[800],
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            if (NewValue.text.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.grey[300],
                                    content: Text(
                                      "Please fill the blank",
                                      style:
                                          GoogleFonts.chivo(color: Colors.red),
                                    ),
                                  );
                                },
                              );
                            } else {
                              Navigator.pop(context);

                              updateUserProfile(NewValue.text, "about");
                            }
                          },
                          child: Container(
                            width: 120,
                            height: 25,
                            child: Center(
                              child: Text(
                                "SAVE",
                                style: GoogleFonts.changaOne(
                                  color: Colors.blue[800],
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  )
                ],
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text(
          "Personal information",
          style: GoogleFonts.changaOne(),
        ),
      ),
      backgroundColor: Colors.grey[300],
      body: ListView(
        children: [
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              SizedBox(
                width: 20,
              ),
              Expanded(
                  flex: 2,
                  child: Container(
                    child: Column(
                      children: [
                        Text(
                          "Your profile information on Wanderlust services",
                          style: GoogleFonts.changaOne(
                              fontSize: 25, color: Colors.blue[800]),
                        ),
                        Text(
                          "Your personal information and options to manage it. You can make some of your information, such as your contact details, visible to others, making it easier for them to reach you. You can also see a summary of your profiles.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black38,
                          ),
                        )
                      ],
                    ),
                  )),
              Expanded(
                  flex: 1,
                  child: Container(
                    child: Center(
                      child: Icon(
                        Icons.account_box_outlined,
                        color: Colors.blue[800],
                        size: 90,
                      ),
                    ),
                  )),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                    color: Colors.black38,
                  )),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Primary informations",
                            style: GoogleFonts.chivo(
                                fontSize: 20, color: Colors.blue[800]),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Some informations,can visible",
                            style: GoogleFonts.robotoMono(
                                fontSize: 15, color: Colors.black38),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "by other Wanderlust users",
                            style: GoogleFonts.robotoMono(
                                fontSize: 15, color: Colors.black38),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 65,
                            child: Text(
                              "Picture",
                              style: GoogleFonts.robotoMono(
                                  fontSize: 15, color: Colors.blue[800]),
                            ),
                          ),
                          Container(
                            child: Text(
                              "  Personalize your account ",
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black38),
                            ),
                          ),
                          StreamBuilder<DocumentSnapshot>(
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

                              final String downloadUrl = data?['ppUrl'] ?? null;

                              return CircleAvatar(
                                backgroundImage: downloadUrl != null
                                    ? Image.network(downloadUrl).image
                                    : null,
                                child: downloadUrl == null
                                    ? Icon(Icons.person)
                                    : null,
                              );
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              myAlert();
                            },
                            child: CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              child: ClipOval(
                                child: Icon(
                                  Icons.cameraswitch_outlined,
                                  color: Colors.blue[800],
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        thickness: 2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            child: Text(
                              "Nickname",
                              style: GoogleFonts.robotoMono(
                                  fontSize: 15, color: Colors.blue[800]),
                            ),
                          ),
                          Container(
                            width: 218,
                            child: buildData(
                                context, "nickname", Colors.black38, 15),
                          ),
                          IconButton(
                              onPressed: () {
                                EditInfo("nickname");
                              },
                              icon: Icon(Icons.arrow_forward_ios))
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        thickness: 2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 65,
                            child: Text(
                              "Name",
                              style: GoogleFonts.robotoMono(
                                  fontSize: 15, color: Colors.blue[800]),
                            ),
                          ),
                          Container(
                            width: 227,
                            child: Row(
                              children: [
                                buildData(context, "name", Colors.black38, 15),
                                buildData(
                                    context, "surname", Colors.black38, 15),
                              ],
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                EditName();
                              },
                              icon: Icon(Icons.arrow_forward_ios))
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        thickness: 2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 65,
                            child: Text(
                              "Country",
                              style: GoogleFonts.robotoMono(
                                  fontSize: 15, color: Colors.blue[800]),
                            ),
                          ),
                          Container(
                            width: 227,
                            child: buildData(
                                context, "country", Colors.black38, 15),
                          ),
                          IconButton(
                              onPressed: () {
                                EditCountry();
                              },
                              icon: Icon(Icons.arrow_forward_ios))
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        thickness: 2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 65,
                            child: Text(
                              "Birth day",
                              style: GoogleFonts.robotoMono(
                                  fontSize: 15, color: Colors.blue[800]),
                            ),
                          ),
                          Container(
                            width: 227,
                            child: buildData(
                                context, "birthdate", Colors.black38, 15),
                          ),
                          IconButton(
                              onPressed: () {
                                _showDatepicker();
                              },
                              icon: Icon(Icons.arrow_forward_ios))
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                    color: Colors.black38,
                  )),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "About me",
                            style: GoogleFonts.chivo(
                                fontSize: 20, color: Colors.blue[800]),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 70,
                            child: Text(
                              "About me",
                              style: GoogleFonts.robotoMono(
                                  fontSize: 14, color: Colors.blue[800]),
                            ),
                          ),
                          Container(
                            width: 222,
                            child: Text(
                              "  Allows other users to learn You! ",
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black38),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                EditAbout();
                              },
                              icon: Icon(Icons.arrow_forward_ios))
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                    color: Colors.black38,
                  )),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Contact informations",
                            style: GoogleFonts.chivo(
                                fontSize: 20, color: Colors.blue[800]),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 65,
                            child: Text(
                              "Email",
                              style: GoogleFonts.robotoMono(
                                  fontSize: 15, color: Colors.blue[800]),
                            ),
                          ),
                          Container(
                            width: 227,
                            child: Text(
                              " $email ",
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black38),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(
                        thickness: 2,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 60,
                            child: Text(
                              "Phone",
                              style: GoogleFonts.robotoMono(
                                  fontSize: 15, color: Colors.blue[800]),
                            ),
                          ),
                          Container(
                            width: 232,
                            child:
                                buildData(context, "phone", Colors.black38, 15),
                          ),
                          IconButton(
                              onPressed: () {
                                EditPhone();
                              },
                              icon: Icon(Icons.arrow_forward_ios))
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                    color: Colors.black38,
                  )),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Password",
                            style: GoogleFonts.robotoMono(
                                fontSize: 20, color: Colors.blue[800]),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "A secure password helps",
                            style: GoogleFonts.robotoMono(
                                fontSize: 15, color: Colors.black38),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "protect your Wanderlust account",
                            style: GoogleFonts.robotoMono(
                                fontSize: 15, color: Colors.black38),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: 70,
                            child: Text(
                              "Password",
                              style: GoogleFonts.robotoMono(
                                  fontSize: 14, color: Colors.blue[800]),
                            ),
                          ),
                          Container(
                            width: 222,
                            child: Text(
                              "  *********  ",
                              style: TextStyle(
                                  fontSize: 15, color: Colors.black38),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                sendVerification();
                              },
                              icon: Icon(Icons.arrow_forward_ios))
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}
