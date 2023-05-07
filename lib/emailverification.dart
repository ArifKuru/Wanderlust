import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderlust/main.dart';
import 'package:wanderlust/signupdocs/services/auh.dart';

class EmailVerify extends StatefulWidget {
  const EmailVerify({Key? key}) : super(key: key);

  @override
  State<EmailVerify> createState() => _EmailVerifyState();
}

class _EmailVerifyState extends State<EmailVerify> {
  AuthService _authService = AuthService();

  bool verified = false;
  bool canResend = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    verified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!verified) {
      sendVerificationEmail();
    }

    timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified());
  }

  @override
  void dispose() {
    void dispose() {
      timer?.cancel();

      super.dispose();
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      verified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (verified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() {
        canResend = false;
      });

      await Future.delayed(Duration(seconds: 30));
      setState(() {
        canResend = true;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: ListView(
        children: [
          SizedBox(height: 30),
          Icon(Icons.security, color: Colors.blue[800], size: 60),
          SizedBox(height: 30),
          Center(
            child: Text(
              "\"YOU MUST\"",
              style: GoogleFonts.robotoMono(fontSize: 25, color: Colors.blue),
            ),
          ),
          SizedBox(height: 5),
          Center(
            child: Text(
              "\"verify your email\"",
              style: GoogleFonts.robotoMono(fontSize: 25, color: Colors.blue),
            ),
          ),
          SizedBox(height: 30),
          Container(
            height: 45,
            width: 350,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0), color: Colors.orange),
            child: Center(
              child: Text(
                "A VERIFICATION EMAIL HAS BEEN SENT",
                style: GoogleFonts.changaOne(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          SizedBox(height: 40),
          BigIcon(verified),
          SizedBox(height: 40),
          Navigation(verified),
          SizedBox(
            height: 45,
          ),
          SizedBox(
            height: 25,
          ),
          Cancel(verified),
          Center(child: ResendButton(canResend, verified)),
        ],
      ),
    );
  }

  Widget Cancel(bool verified) {
    if (verified) {
      return SizedBox(
        height: 45,
      );
    } else {
      return TextButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateColor.resolveWith((states) => Colors.orange)),
        onPressed: () async {
          CollectionReference userRef =
              FirebaseFirestore.instance.collection("Person");
          //   _authService.signOut();
          _authService.signOut();
          Navigator.pushReplacementNamed(context, "/login");
        },
        child: Container(
          height: 30,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0), color: Colors.orange),
          child: Center(
            child: Text(
              "CANCEL",
              style: GoogleFonts.changaOne(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      );
    }
  }

  Widget BigIcon(bool verified) {
    if (verified) {
      return Icon(
        Icons.done_outline,
        color: Colors.green,
        size: 100,
      );
    } else {
      return Icon(
        Icons.clear_outlined,
        color: Colors.red,
        size: 100,
      );
    }
  }

  Widget ResendButton(bool canResend, bool verified) {
    if (verified) {
      return Center(
        child: Text(
          "Your email ${FirebaseAuth.instance.currentUser!.email}\nhas been verified succesfully...",
          style: GoogleFonts.chivo(color: Colors.black38),
        ),
      );
    }
    if (canResend) {
      return Column(
        children: [
          Center(
              child: Text(
            "Hasn't taken email ?",
            style: GoogleFonts.robotoMono(
              color: Colors.black38,
            ),
          )),
          TextButton(
            onPressed: () {
              sendVerificationEmail();
              setState(() {
                canResend = false;
              });
            },
            child: Text(
              "RESEND EMAIL",
              style: GoogleFonts.anton(fontSize: 20, color: Colors.blue[800]),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Center(
              child: Text(
            "Hasn't taken email ?",
            style: GoogleFonts.robotoMono(
              color: Colors.black38,
            ),
          )),
          Text(
            "VERIFACTION EMAIL CAN SEND ONCE IN 30 SECOND",
            style: GoogleFonts.anton(fontSize: 20, color: Colors.black38),
          ),
        ],
      );
    }
  }

  Widget Navigation(bool verified) {
    dynamic color = Colors.grey;
    if (verified == true) {
      color = Colors.blue[800];
      return TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/fillname');
        },
        child: Container(
          height: 45,
          width: 350,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: color),
          //color: Colors.black,
          child: Center(
            child: Text(
              "CONTINUE",
              style: GoogleFonts.changaOne(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      );
    } else {
      color = Colors.grey;
      return Row(
        children: [
          SizedBox(
            width: 30,
          ),
          Container(
            height: 45,
            width: 350,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: color),
            //color: Colors.black,
            child: Center(
              child: Text(
                "CONTINUE TO MAIN PAGE",
                style: GoogleFonts.changaOne(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      );
    }
  }
}
