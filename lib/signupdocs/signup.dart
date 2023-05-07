import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wanderlust/signupdocs/services/auh.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  AuthService _authService = AuthService();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController passwordConfirm = TextEditingController();
  int errortest = 0;
  bool savepassword2 = true;
  bool savepassword = true;
  Color color2 = Colors.black;
  Color color = Colors.black;
  IconData _Eye = Icons.remove_red_eye_outlined;
  IconData _Eye2 = Icons.remove_red_eye_outlined;
  //AuthService _authService = AuthService();
  static bool isLoading = false;
  void signUserUp() async {
    if (password.text.isEmpty ||
        password.text.isEmpty ||
        passwordConfirm.text.isEmpty) {
      setState(() {
        errortest = 3;
      });
    } else {
      if (password.text != passwordConfirm.text) {
        setState(() {
          errortest = 4;
        });
      } else {
        setState(() {
          isLoading =
              true; // set isLoading to true to show the progress indicator
        });
        try {
          await _authService.createPerson(email.text, password.text);
          Navigator.pushReplacementNamed(context, '/emailverify');
          email.text = "";
          password.text = "";
          passwordConfirm.text = "";
          setState(() {
            isLoading =
                false; // set isLoading to false to hide the progress indicator
          });
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            print('The password provided is too weak.');
            setState(() {
              errortest = 1;
              isLoading = false;
            });
          } else if (e.code == 'email-already-in-use') {
            print('The account already exists for that email.');
            setState(() {
              errortest = 2;
              isLoading = false;
            });
          }
        } catch (e) {
          print(e);
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Center(
                child: Icon(
                  Icons.map,
                  color: Colors.blue[800],
                  size: 60,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: Text(
                  "\"START YOUR JOURNEY\"",
                  style:
                      GoogleFonts.robotoMono(fontSize: 25, color: Colors.blue),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  SizedBox(width: 55),
                  Text("Email adress"),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 350,
                // height: 45,
                child: TextFormField(
                  controller: email,
                  onChanged: (String str) {
                    setState(() {
                      errortest = 0;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Type your email here !",
                    // hintStyle: TextStyle(color: Colors.blue),
                    prefixIcon: Icon(
                      Icons.account_box_outlined,
                      color: Colors.blue,
                    ),
                    border: OutlineInputBorder(
                        //borderSide: BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  SizedBox(width: 55),
                  Text("Password"),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 350,
                //   height: 45,
                child: TextFormField(
                  obscureText: savepassword,
                  controller: password,
                  onChanged: (String str) {
                    setState(() {
                      errortest = 0;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Type your password here !",
                    suffixIcon: TextButton(
                        onPressed: () {
                          setState(() {
                            if (savepassword == true) {
                              color = Colors.blue;
                              savepassword = false;
                              _Eye = Icons.visibility_off_outlined;
                            } else {
                              color = Colors.black;
                              savepassword = true;
                              _Eye = Icons.remove_red_eye_outlined;
                            }
                          });
                        },
                        child: Icon(
                          _Eye,
                          color: color,
                        )),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Colors.blue,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  SizedBox(width: 55),
                  Text("Password verification"),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 350,
                //  height: 45,
                child: TextFormField(
                  obscureText: savepassword2,
                  controller: passwordConfirm,
                  onChanged: (String str) {
                    setState(() {
                      errortest = 0;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Type your password here again !",
                    suffixIcon: TextButton(
                        onPressed: () {
                          setState(() {
                            if (savepassword2 == true) {
                              color2 = Colors.blue;
                              savepassword2 = false;
                              _Eye2 = Icons.visibility_off_outlined;
                            } else {
                              color2 = Colors.black;
                              savepassword2 = true;
                              _Eye2 = Icons.remove_red_eye_outlined;
                            }
                          });
                        },
                        child: Icon(
                          _Eye2,
                          color: color2,
                        )),
                    prefixIcon: Icon(
                      Icons.lock_person_outlined,
                      color: Colors.blue,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              TestErrors(errortest),
              TextButton(
                onPressed: () {
                  signUserUp();
                },
                child: Container(
                  height: 45,
                  width: 350,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue[800]),
                  //color: Colors.black,
                  child: Center(
                    child: Text(
                      "SIGN UP",
                      style: GoogleFonts.changaOne(
                          color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 14,
              ),
              Text("Already on Wanderlust?"),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(
                  "Login",
                  style:
                      GoogleFonts.anton(fontSize: 20, color: Colors.blue[800]),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  //1-weak sifre 2-kayıtlı 3-boş var 4-eşleşmedi

  Widget TestErrors(int error) {
    if (error == 0) {
      return SizedBox(
        height: 30,
      );
    } else if (error == 1) {
      return Column(
        children: [
          SizedBox(
            height: 5,
          ),
          Text(
            "The password provided is too weak.",
            style: TextStyle(color: Colors.red),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      );
    } else if (error == 2) {
      return Column(
        children: [
          SizedBox(
            height: 5,
          ),
          Text(
            "The account already exists for that email.",
            style: TextStyle(color: Colors.red),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      );
    } else if (error == 3) {
      return Column(
        children: [
          SizedBox(
            height: 5,
          ),
          Text(
            "Blanks must be filled.",
            style: TextStyle(color: Colors.red),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          SizedBox(
            height: 5,
          ),
          Text(
            "Passwords did not match.",
            style: TextStyle(color: Colors.red),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      );
    }
  }
}
