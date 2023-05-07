import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  int errortest = 0;
  bool savepassword = true;
  Color color = Colors.black;
  IconData _Eye = Icons.remove_red_eye_outlined;
  // AuthService _authService = AuthService();
  void signUserIn() async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(color: Colors.blue[800]),
          );
        });
    if (email.text.isEmpty || password.text.isEmpty) {
      setState(() {
        errortest = 3;
      });
      Navigator.pop(context);
    } else {
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: email.text, password: password.text)
            .then((value) => Navigator.pushReplacementNamed(context, '/myapp'));
        Navigator.pop(context);
        errortest = 0;
        email.text = "";
        password.text = "";
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          setState(() {
            errortest = 1;
            Navigator.pop(context);
          });
        } else if (e.code == 'wrong-password') {
          setState(() {
            errortest = 2;
            Navigator.pop(context);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Icon(
                Icons.map,
                color: Colors.blue[800],
                size: 60,
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                "\"WELCOME TO WANDERLUST\"",
                style: GoogleFonts.robotoMono(fontSize: 25, color: Colors.blue),
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
                //  height: 45,
                child: TextFormField(
                  onChanged: (String str) {
                    setState(() {
                      errortest = 0;
                    });
                  },
                  controller: email,
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
              EmailError(errortest),
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
                //height: 60,
                child: TextFormField(
                  onChanged: (String str) {
                    setState(() {
                      errortest = 0;
                    });
                  },
                  controller: password,
                  decoration: InputDecoration(
                    hintText: "Type your password here !",
                    suffixIcon: TextButton(
                        onPressed: () {
                          setState(() {
                            if (savepassword == true) {
                              savepassword = false;
                              color = Colors.blue;
                              _Eye = Icons.visibility_off_outlined;
                            } else {
                              savepassword = true;
                              color = Colors.black;
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
                  obscureText: savepassword,
                ),
              ),
              PasswordError(errortest),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/passwordreset');
                      },
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(color: Colors.blue[800]),
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  signUserIn();
                },
                child: Container(
                  height: 45,
                  width: 350,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.blue[800]),
                  //color: Colors.black,
                  child: Center(
                    child: Text(
                      "LOGIN",
                      style: GoogleFonts.changaOne(
                          color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              /*Text("Or continue with"),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: ClipOval(
                      child: Image.asset(
                        "assets/signuppageimages/google.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  CircleAvatar(
                    radius: 30,
                    child: ClipOval(
                      child: Image.asset(
                        "assets/signuppageimages/facebookl.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 35,
                  ),
                  CircleAvatar(
                    radius: 30,
                    child: ClipOval(
                      child: Image.asset(
                        "assets/signuppageimages/twittere.png",
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ],
              ),*/
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 20,
              ),
              Text("Not on Wanderlust yet?"),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                child: Text(
                  "Sign Up",
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

  Widget EmailError(int error) {
    if (error == 1) {
      return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 120.0),
          child: Text(
            "No user found for that email.",
            style: TextStyle(color: Colors.red),
          ),
        ),
        SizedBox(
          height: 10,
        )
      ]);
    } else {
      return SizedBox(
        height: 30,
      );
    }
  }

  Widget PasswordError(int error) {
    if (error == 2) {
      return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 58.0),
          child: Text(
            "Wrong password provided for that user.",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ]);
    } else if (error == 3) {
      return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(
          height: 5,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 170.0),
          child: Text(
            "Blanks must be filled.",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ]);
    } else {
      return SizedBox(
        height: 10,
      );
    }
  }
}

class passwordResetPage extends StatefulWidget {
  const passwordResetPage({Key? key}) : super(key: key);

  @override
  State<passwordResetPage> createState() => _passwordResetPageState();
}

class _passwordResetPageState extends State<passwordResetPage> {
  final TextEditingController email = TextEditingController();
  String errorMessage = "";
  bool error = false;
  Future resetUserPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email.text.trim());
      setState(() {
        errorMessage = "Reset link sent! check your email";
        error = false;
      });
    } on FirebaseAuthException catch (e) {
      print(e);
      setState(() {
        errorMessage = e.toString();
        error = true;
      });
    }
  }

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Center(
                child: Icon(
                  Icons.support_agent,
                  color: Colors.blue[800],
                  size: 60,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: Text(
                  "\"WE\'RE ALWAYS HERE\"",
                  style: GoogleFonts.robotoMono(
                      fontSize: 25, color: Colors.blueGrey),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: Text(
                  "\"FOR TECHNICAL SUPPORT\"",
                  style:
                      GoogleFonts.robotoMono(fontSize: 25, color: Colors.blue),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Container(
                width: 350,
                //  height: 45,
                child: TextFormField(
                  controller: email,
                  onChanged: (String str) {
                    setState(() {
                      errorMessage = "";
                      error = false;
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
                height: 40,
              ),
              TextButton(
                onPressed: () {
                  resetUserPassword();
                },
                child: Container(
                  height: 45,
                  width: 350,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blueGrey[800]),
                  //color: Colors.black,
                  child: Center(
                    child: Text(
                      "REQUEST RESET LINK",
                      style: GoogleFonts.changaOne(
                          color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
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
                      "BACK TO LOGIN",
                      style: GoogleFonts.changaOne(
                          color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              message(errorMessage, error),
            ],
          ),
        ),
      ),
    );
  }

  Widget message(String error, bool check) {
    if (check == true) {
      return Center(
        child: Text(
          error,
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
      );
    } else {
      return Center(
        child: Text(
          error,
          style: GoogleFonts.robotoMono(color: Colors.blue[800], fontSize: 18),
        ),
      );
    }
  }
}
