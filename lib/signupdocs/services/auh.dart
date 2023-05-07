import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String about = "Write here about you to allow other users to learn about you!";

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //ÇIKIŞ YAP FOKSIYONU
  signOut() async {
    return await _auth.signOut();
  }

  void verifyEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    if (!(user!.emailVerified)) {
      user.sendEmailVerification();
    }
  }

//KAYIT OL FONKSIYONU
  Future<User?> createPerson(String email, String password) async {
    var user = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await _firestore.collection("Person").doc(user.user!.uid).set({
      'email': email,
      'about': about,
      'name': "",
      'ppUrl': "https://i.imgflip.com/6yvpkj.jpg"
    });
    return user.user;
  }
}
