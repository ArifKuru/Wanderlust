import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PostDetail extends StatefulWidget {
  final DocumentSnapshot postSnapshot;
  PostDetail({
    required this.postSnapshot,
  });
  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  TextEditingController comment = TextEditingController();

  void saveToFirebase(TextEditingController comment) async {
    final user = FirebaseAuth.instance.currentUser!.uid;
    final content = comment.text;
    final date = DateTime.now();
    final numOfComments = widget.postSnapshot.get("comment");

    final docRef = widget.postSnapshot.reference;
    final subCollectionRef = docRef.collection('Comments').doc();
    await docRef.set({
      "comment": numOfComments + 1,
    }, SetOptions(merge: true));

    await subCollectionRef.set({
      'uid': user,
      'content': content,
      'date': date,
    });
  }

  Stream<QuerySnapshot> _getPostsStream() {
    return FirebaseFirestore.instance.collection('Posts').snapshots();
  }

  Stream<QuerySnapshot> _getPersonStream() {
    return FirebaseFirestore.instance.collection('Person').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        height: MediaQuery.of(context).size.height + 200,
        child: ListView(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 200,
              child: StreamBuilder(
                  stream: _getPostsStream(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    String body = widget.postSnapshot.get('Body');
                    String imageUrl = widget.postSnapshot.get('ImageUrl');
                    var uid = widget.postSnapshot.get("uid");
                    Timestamp date = widget.postSnapshot.get('date');
                    int comment = widget.postSnapshot.get('comment');
                    int month = date.toDate().month;
                    int day = date.toDate().day;
                    int hour = date.toDate().hour;
                    int minute = date.toDate().minute;
                    return ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    StreamBuilder<QuerySnapshot>(
                                        stream: _getPersonStream(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<QuerySnapshot>
                                                snapshot) {
                                          if (!snapshot.hasData) {
                                            return Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                          var author = snapshot.data!.docs
                                              .firstWhere(
                                                  (doc) => doc.id == uid);
                                          String nickname =
                                              author.get("nickname");
                                          String ppUrl = author.get("ppUrl");

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  backgroundImage:
                                                      NetworkImage(ppUrl),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 15.0),
                                                  child: Text(
                                                    nickname,
                                                    style: GoogleFonts.chivo(
                                                        fontSize: 20,
                                                        color:
                                                            Colors.blue[800]),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                    Text(
                                      "${day < 10 ? '0${day.toString()}' : day.toString()}/${month < 10 ? '0${month.toString()}' : month.toString()} at ${hour}:${minute < 10 ? '0${minute.toString()}' : minute.toString()}",
                                      style: GoogleFonts.chivo(
                                          color: Colors.black38),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Text(
                                  body,
                                  style: GoogleFonts.chivo(fontSize: 20),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
            ),
            Container(
              height: 100,
              child: StreamBuilder<QuerySnapshot>(
                stream: widget.postSnapshot.reference
                    .collection('Comments')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('Loading...');
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final document = snapshot.data!.docs[index];
                      final content = document.get("content");
                      Timestamp date = document.get("date");
                      DateTime alldate = date.toDate();
                      int day = alldate.day;
                      int month = alldate.month;
                      int hour = alldate.hour;
                      int minute = alldate.minute;
                      var uid = document.get("uid");
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StreamBuilder<QuerySnapshot>(
                                stream: _getPersonStream(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  var author = snapshot.data!.docs
                                      .firstWhere((doc) => doc.id == uid);
                                  String nickname = author.get("nickname");
                                  String ppUrl = author.get("ppUrl");

                                  return Row(
                                    children: [
                                      Container(
                                        height: 25,
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(ppUrl),
                                        ),
                                      ),
                                      Text(
                                        nickname,
                                        style: GoogleFonts.chivo(
                                            fontSize: 12,
                                            color: Colors.blue[800]),
                                      ),
                                    ],
                                  );
                                }),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                content,
                                style: GoogleFonts.chivo(fontSize: 15),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "${day < 10 ? '0${day.toString()}' : day.toString()}/${month < 10 ? '0${month.toString()}' : month.toString()} at ${hour}:${minute < 10 ? '0${minute.toString()}' : minute.toString()}",
                                style: GoogleFonts.chivo(color: Colors.black38),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              child: TextFormField(
                controller: comment,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: TextButton(
                      onPressed: () {
                        saveToFirebase(comment);
                      },
                      child: Icon(Icons.send)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
