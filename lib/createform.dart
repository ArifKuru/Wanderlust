import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderlust/PostDetailedPage.dart';

class TravelGuideApp extends StatefulWidget {
  const TravelGuideApp({Key? key}) : super(key: key);

  @override
  State<TravelGuideApp> createState() => _TravelGuideAppState();
}

class _TravelGuideAppState extends State<TravelGuideApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddPost();
            },
          );
        },
        backgroundColor: Colors.blue[800],
        shape: Border.all(color: Colors.blue),
      ),
      backgroundColor: Colors.grey[300],
      body: ListView(
        children: [
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Find travel mate from other Travellers",
              style: GoogleFonts.chivo(color: Colors.blue[800], fontSize: 15),
            ),
          ),
          PersonList(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "See posts from all over world ! ",
              style: GoogleFonts.chivo(color: Colors.blue[800], fontSize: 15),
            ),
          ),
          PostList()
        ],
      ),
    );
  }
}

class PersonList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Person').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        return Container(
          height: 100.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              String name = snapshot.data!.docs[index]['name'];
              if (name.isEmpty) {
                // Boş olanları atla
                return Container();
              }
              String uid = snapshot.data!.docs[index].id;
              if (uid == currentUserUid) {
                // Mevcut kullanıcının dokümanını atla
                return Container();
              }
              String nickname = snapshot.data!.docs[index]['nickname'];
              String ppUrl = snapshot.data!.docs[index]['ppUrl'];
              return Card(
                child: Container(
                  height: 100,
                  width: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: NetworkImage(ppUrl),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        nickname,
                        style: GoogleFonts.chivo(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class AddPost extends StatefulWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _image; // Image dosyası için tanımlanan değişken
  Future<String> uploadImageToFirebase(File file) async {
    // Storage referansı oluşturun
    String randomString = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('PostsPicture')
        .child(randomString)
        .child('photo.png');

    // Resmi Storage'a yükle
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);

    // Resmin URL'sini al
    String downloadUrl = await snapshot.ref.getDownloadURL();

    // URL'yi döndür
    return downloadUrl;
  }

  uploadPost() async {
    // Yüklenen resmin URL'sini al
    String imageUrl = await uploadImageToFirebase(_image!);

    // Get the current user's ID
    String userId = _auth.currentUser!.uid;

    // Get a reference to the user document in Firestore
    DocumentReference userRef = _firestore.collection('Posts').doc();

    // Update the user document with the new data
    await userRef.set({
      'Body': body.text,
      'vote': 0,
      'comment': 0,
      'uid': userId,
      'date': DateTime.now(),
      'ImageUrl': imageUrl,
    }, SetOptions(merge: true));
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _getCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  TextEditingController body = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        scrollable: true,
        backgroundColor: Colors.grey[300],
        content: Column(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
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

                        final data =
                            snapshot.data?.data() as Map<String, dynamic>?;

                        final String downloadUrl = data?['ppUrl'] ?? null;
                        final String nickname = data?["nickname"] ?? null;

                        return Row(
                          children: [
                            SizedBox(
                              width: 50,
                            ),
                            CircleAvatar(
                              backgroundImage: downloadUrl != null
                                  ? Image.network(
                                      downloadUrl,
                                      fit: BoxFit.scaleDown,
                                    ).image
                                  : null,
                              child: downloadUrl == null
                                  ? Icon(Icons.person)
                                  : null,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              nickname,
                              style: GoogleFonts.chivo(fontSize: 20),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Text(
                    "Share a post !",
                    style: GoogleFonts.chivo(
                        color: Colors.blue[800], fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Expanded(
                    child: SizedBox(
                      child: TextField(
                        controller: body,
                        decoration: InputDecoration(
                            // hintStyle: TextStyle(color: Colors.blue),
                            ),
                      ),
                    ),
                  ),
                ),
                _image == null
                    ? Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: _getImage,
                              child: Icon(
                                Icons.image,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: _getCamera,
                              child: Icon(
                                Icons.camera,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      height: 100,
                                      width: 100,
                                      child: Image.file(_image!)),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: _getImage,
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                  onPressed: _getCamera,
                                  child: Icon(
                                    Icons.camera,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: uploadPost,
                        child: Text(
                          "SHARE",
                          style: GoogleFonts.changaOne(
                              color: Colors.blue[800], fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ));
  }
}

class PostList extends StatefulWidget {
  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  static int vote = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> _getPostsStream() {
    return _firestore.collection('Posts').snapshots();
  }

  Stream<QuerySnapshot> _getPersonStream() {
    return _firestore.collection('Person').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Posts')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.size,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            String CurrentUid = FirebaseAuth.instance.currentUser!.uid;

            Future<void> AddLike(int _voteStatu, bool up) async {
              DocumentReference PostRef = snapshot.data!.docs[index].reference;
              int vote = snapshot.data!.docs[index].get("vote");
              int change = 0;
              DocumentReference LikeRef = snapshot.data!.docs[index].reference
                  .collection("Rating")
                  .doc(CurrentUid);
              DocumentSnapshot LikeSnap = await LikeRef.get();
              Map<String, dynamic>? data =
                  LikeSnap.data() as Map<String, dynamic>?;
              //3 Boş daha önce değerlendırılmemış
              //2 Değerlendırılmış ve downvote
              //1 Değerlendırılmış ve upvote
              // Update the user document with the new data
              print(_voteStatu);
              if (_voteStatu == 1 && up == true) {
                setState(() {
                  change = -1;
                });
                LikeRef.delete();
              } else if (_voteStatu == 1 && up == false) {
                setState(() {
                  change = -2;
                });
                await LikeRef.set({
                  "up": false,
                } /*, SetOptions(merge: true)*/);
                print(_voteStatu);
              } else if (_voteStatu == 2 && up == true) {
                setState(() {
                  change = 2;
                });

                await LikeRef.set({
                  "up": true,
                });
              } else if (_voteStatu == 2 && up == false) {
                setState(() {
                  change = 1;
                });

                LikeRef.delete();
              } else if (_voteStatu == 3) {
                if (up) {
                  setState(() {
                    change = 1;
                  });
                } else {
                  setState(() {
                    change = -1;
                  });
                }
                await LikeRef.set({
                  "up": up,
                });
              }
              await PostRef.set({
                "vote": vote + change,
              }, SetOptions(merge: true));

              /*if (_voteStatu == 1) {
                if (up = true) {
                  LikeRef.delete();
                } else {
                  await LikeRef.set({
                    "up": false,
                  }, SetOptions(merge: true));
                  print(_voteStatu);
                }
              } else if (_voteStatu == 2) {
                if (up = true) {
                  await LikeRef.set({
                    "up": true,
                  }, SetOptions(merge: true));
                } else {
                  LikeRef.delete();
                }
              } else {
                await LikeRef.set({
                  "up": up,
                }, SetOptions(merge: true));
              }*/
            }

            String DocId = snapshot.data!.docs[index].id;

            Future<int> checkVote() async {
              try {
                var uid = FirebaseAuth.instance.currentUser!.uid;
                var snapshot = await FirebaseFirestore.instance
                    .collection('Posts')
                    .doc(DocId)
                    .collection('Rating')
                    .doc(uid)
                    .get();
                if (snapshot.exists) {
                  bool up = snapshot.data()!['up'];
                  if (up) {
                    return 1;
                  } else {
                    return 2;
                  }
                } else {
                  return 3;
                }
              } catch (e) {
                print('Error checking vote: $e');
                return 0;
              }
            }

            int _vote = snapshot.data!.docs[index].get('vote');
            String body = snapshot.data!.docs[index].get('Body');
            String imageUrl = snapshot.data!.docs[index].get('ImageUrl');
            Timestamp date = snapshot.data!.docs[index].get('date');
            int comment = snapshot.data!.docs[index].get('comment');
            int month = date.toDate().month;
            int day = date.toDate().day;
            int hour = date.toDate().hour;
            int minute = date.toDate().minute;
            String uid = snapshot.data!.docs[index].get('uid');
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(ppUrl),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      child: Text(
                                        nickname,
                                        style: GoogleFonts.chivo(
                                            fontSize: 20,
                                            color: Colors.blue[800]),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        Text(
                          "${day < 10 ? '0${day.toString()}' : day.toString()}/${month < 10 ? '0${month.toString()}' : month.toString()} at ${hour}:${minute < 10 ? '0${minute.toString()}' : minute.toString()}",
                          style: GoogleFonts.chivo(color: Colors.black38),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text(
                      body,
                      style: GoogleFonts.chivo(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 185,
                      width: 390,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 15,
                            ),
                            FutureBuilder<int>(
                              future: checkVote(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  int? vote = snapshot.data;
                                  return Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          AddLike(vote!, true);
                                          setState(
                                              () {}); // setState fonksiyonu çağrılarak widget güncelleniyor
                                        },
                                        child: Icon(
                                          Icons.arrow_upward_rounded,
                                          color: vote == 1
                                              ? Colors.blue
                                              : Colors.black,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          AddLike(vote!, false);
                                          setState(
                                              () {}); // setState fonksiyonu çağrılarak widget güncelleniyor
                                        },
                                        child: Icon(
                                          Icons.arrow_downward_rounded,
                                          color: vote == 2
                                              ? Colors.blue
                                              : Colors.black,
                                        ),
                                      ),
                                      Text(_vote.toString()),
                                    ],
                                  );
                                } else if (snapshot.hasError) {
                                  return Text("Hata oluştu: ${snapshot.error}");
                                } else {
                                  return CircularProgressIndicator();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetail(
                                    postSnapshot: snapshot.data!.docs[index]),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.comment),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(comment.toString()),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
