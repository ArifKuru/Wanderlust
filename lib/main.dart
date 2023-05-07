import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wanderlust/CHATBOT/Chat_bot.dart';
import 'package:wanderlust/CityPage.dart';
import 'package:wanderlust/Favouries/Favouries.dart';
import 'package:wanderlust/Geocoding/GetLocation.dart';
import 'package:wanderlust/Geocoding/YourLocationMap.dart';
import 'package:wanderlust/createform.dart';
import 'package:wanderlust/emailverification.dart';
import 'package:wanderlust/location.dart';
import 'package:wanderlust/routes.dart';
import 'package:wanderlust/signupdocs/services/auh.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:wanderlust/weather.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  void dispose() {
    super.dispose();
  }

  int page = 0;
  static int kindex = 1;
  AuthService _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SafeArea(
          child: Scaffold(
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 5,
                ),
                child: GNav(
                  onTabChange: (index) {
                    setState(() {
                      page = index;
                    });
                  },
                  gap: 8,
                  padding: EdgeInsets.all(10),
                  activeColor: Colors.white,
                  tabBackgroundColor: Colors.lightBlue,
                  tabs: [
                    GButton(
                      icon: Icons.home_outlined,
                      text: "Home",
                    ),
                    GButton(
                      icon: Icons.cloud_outlined,
                      text: "Weather",
                    ),
                    GButton(
                      icon: Icons.favorite_border_outlined,
                      text: "Favouries",
                    ),
                    GButton(
                      icon: Icons.groups_2_outlined,
                      text: "Form",
                    ),
                    GButton(
                      icon: Icons.location_on_outlined,
                      text: "Find Location",
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.grey[300],
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                backgroundColor: Colors.blue[800],
                title: Icon(Icons.map),
                centerTitle: true,
                leading: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/profile');
                  },
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

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      final data =
                          snapshot.data?.data() as Map<String, dynamic>?;

                      final String downloadUrl = data?['ppUrl'] ?? null;

                      return CircleAvatar(
                        backgroundImage: downloadUrl != null
                            ? Image.network(
                                downloadUrl,
                                fit: BoxFit.scaleDown,
                              ).image
                            : null,
                        child: downloadUrl == null ? Icon(Icons.person) : null,
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/searchbar');
                      },
                      child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Center(child: Icon(Icons.search)))),
                ],
              ),
              body: page == 0
                  ? PageView(
                      children: [
                        ListView(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 12,
                                ),
                                Text(
                                  "Plan your next trip over 40 country !",
                                  style: GoogleFonts.chivo(
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                            CityCarousel(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, "/viewallcountry");
                                    },
                                    child: Text(
                                      "View all",
                                      style: GoogleFonts.chivo(
                                          color: Colors.orange),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 14,
                                ),
                                Text(
                                  "You are over here ! ",
                                  style: GoogleFonts.chivo(
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                            // MAP OLACAK
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: YourMap(),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 14,
                                ),
                                Text(
                                  "Nearby you attractions ! ",
                                  style: GoogleFonts.chivo(
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      kindex = 1;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: kindex == 1
                                          ? Colors.blue
                                          : Colors.grey[300],
                                      border: Border.all(
                                        color: kindex == 1
                                            ? Colors.white
                                            : Colors.blue,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: Icon(
                                            Icons.home_outlined,
                                            color: kindex == 1
                                                ? Colors.white
                                                : Colors.blue,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: Text(
                                            "Hotels",
                                            style: GoogleFonts.chivo(
                                              color: kindex == 1
                                                  ? Colors.white
                                                  : Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      kindex = 2;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: kindex == 2
                                          ? Colors.blue
                                          : Colors.grey[300],
                                      border: Border.all(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: Icon(
                                            Icons.museum_outlined,
                                            color: kindex == 2
                                                ? Colors.white
                                                : Colors.blue,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: Text(
                                            "Museums",
                                            style: GoogleFonts.chivo(
                                              color: kindex == 2
                                                  ? Colors.white
                                                  : Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      kindex = 3;
                                    });
                                    print(kindex);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: kindex == 3
                                          ? Colors.blue
                                          : Colors.grey[300],
                                      border: Border.all(color: Colors.blue),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: Icon(
                                            Icons.food_bank_outlined,
                                            color: kindex == 3
                                                ? Colors.white
                                                : Colors.blue,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4.0),
                                          child: Text(
                                            "Restaurants",
                                            style: GoogleFonts.chivo(
                                              color: kindex == 3
                                                  ? Colors.white
                                                  : Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            GetLocation(index: kindex),
                          ],
                        ),
                      ],
                    )
                  : page == 1
                      ? ShowWeather()
                      : page == 2
                          ? Favouries()
                          : page == 3
                              ? TravelGuideApp()
                              : findLocation()),
        ));
  }
}

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<DocumentSnapshot> _documents = [];
  TextEditingController _searchController = TextEditingController();

  void _performSearch(String searchText) async {
    final snap = await _db.collection('Country').get();

    List<DocumentSnapshot> filteredDocs = [];

    snap.docs.forEach((doc) {
      if (doc
          .get('name')
          .toString()
          .toLowerCase()
          .contains(searchText.toLowerCase())) {
        filteredDocs.add(doc);
      }
    });
    setState(() {
      _documents = filteredDocs;
    });
  }

  void dispose() {
    super.dispose();
  }

  void initState() {
    super.initState();
    _performSearch("");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text("Find a destination in 40+ countries"),
          centerTitle: true,
        ),
        body: Container(
          margin: EdgeInsets.only(top: 25, left: 25, right: 25),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 12,
                  ),
                  Text("Search destination",
                      style: GoogleFonts.chivo(color: Colors.blue[800])),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: TextField(
                        controller: _searchController,
                        cursorColor: Colors.grey,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'Find your next location !',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                          prefixIcon: Container(
                            padding: EdgeInsets.all(15),
                            child: Icon(
                              Icons.search,
                              color: Colors.blue[800],
                            ),
                            width: 18,
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _performSearch(value);
                          } else {
                            _performSearch("");
                          }
                        }),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String city = _documents[index].get('name');
                    final String imageUrl = _documents[index].get('image');
                    final String ShortCut = _documents[index].id;
                    return ListTile(
                      title: Text(city),
                      subtitle: Text(ShortCut),
                      leading: Image.network(imageUrl),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CityScreen(city: ShortCut),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CityCarousel extends StatefulWidget {
  @override
  State<CityCarousel> createState() => _CityCarouselState();
}

class _CityCarouselState extends State<CityCarousel> {
  void dispose() {
    super.dispose();
  }

  void AddFavourite(
      String city, String imageUrl, bool isFavourite, String _shortcut) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userRef =
        FirebaseFirestore.instance.collection('Person').doc(currentUser!.uid);
    final favouriteRef = userRef.collection('FavCountries').doc(city);

    if (isFavourite) {
      favouriteRef.delete();
      setState(() {
        isFavourite = false;
      });
    } else {
      favouriteRef.set({
        'name': city,
        'image': imageUrl,
        'shortcut': _shortcut,
      });
      setState(() {
        isFavourite = true;
      });
    }
  }

  Future<bool> checkIfFavourite(String city) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final favCountriesCollection = FirebaseFirestore.instance
        .collection('Person')
        .doc(uid)
        .collection('FavCountries');

    bool isFavourite = false;

    final querySnapshot = await favCountriesCollection.get();
    querySnapshot.docs.forEach((doc) {
      if (doc.id.toString() == city) {
        isFavourite = true;
      }
    });

    return isFavourite;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 256.0,
      width: 390,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Country').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            itemBuilder: (BuildContext context, int index) {
              final String city = documents[index].get('name');
              final String imageUrl = documents[index].get('image');
              final String ShortCut = documents[index].id;
              final Future<bool> isFavourite = checkIfFavourite(city);

              return Padding(
                padding: const EdgeInsets.all(1.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CityScreen(city: ShortCut),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Stack(
                          children: [
                            Container(
                              height: 240.0,
                              width: 390.0,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            FutureBuilder<bool>(
                              future: isFavourite,
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data!) {
                                  return Positioned(
                                    top: 0,
                                    right: 0,
                                    child: ClipOval(
                                      child: TextButton(
                                        onPressed: () {
                                          AddFavourite(
                                              city, imageUrl, true, ShortCut);
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: ClipOval(
                                            child: Icon(
                                              Icons.favorite,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return Positioned(
                                    top: 0,
                                    right: 0,
                                    child: ClipOval(
                                      child: TextButton(
                                        onPressed: () {
                                          AddFavourite(
                                              city, imageUrl, false, ShortCut);
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: ClipOval(
                                            child: Icon(
                                              Icons.favorite_outline,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            Positioned(
                              bottom: 5,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.black38,
                                ),
                                child: Center(
                                  child: Text(
                                    city,
                                    style: GoogleFonts.changaOne(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CityScreen extends StatefulWidget {
  final String city;

  CityScreen({required this.city});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  void dispose() {
    super.dispose();
  }

  void AddFavourite(String city, String imageUrl, bool isFavourite) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userRef =
        FirebaseFirestore.instance.collection('Person').doc(currentUser!.uid);
    final favouriteRef = userRef.collection('FavCountries').doc(city);

    if (isFavourite) {
      favouriteRef.delete();
      setState(() {
        isFavourite = false;
      });
    } else {
      favouriteRef.set({
        'name': city,
        'image': imageUrl,
        'shortcut': _shortCut,
      });
      setState(() {
        isFavourite = true;
      });
    }
  }

  Future<bool> checkIfFavourite(String city) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final favCountriesCollection = FirebaseFirestore.instance
        .collection('Person')
        .doc(uid)
        .collection('FavCountries');

    bool isFavourite = false;

    final querySnapshot = await favCountriesCollection.get();
    querySnapshot.docs.forEach((doc) {
      if (doc.id.toString() == city) {
        isFavourite = true;
      }
    });

    return isFavourite;
  }

  String _country = "";
  String _imageUrl = "";
  String _shortCut = "";
  @override
  void initState() {
    super.initState();
    _getCountryName();
  }

  Future<void> _getCountryName() async {
    final document = await FirebaseFirestore.instance
        .collection("Country")
        .doc(widget.city)
        .get();

    setState(() {
      _imageUrl = document.data()!["image"].toString();
      _country = document.data()!["name"].toString();
      _shortCut = document.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Future<bool> isFavourite = checkIfFavourite(_country);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/CHATBOT');
        },
        child: Icon(Icons.support_agent),
        backgroundColor: Colors.blue[800],
      ),
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        centerTitle: true,
        title: Icon(
          Icons.map,
          color: Colors.white,
        ),
        actions: [
          FutureBuilder<bool>(
            future: isFavourite,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                return Positioned(
                  top: 0,
                  right: 0,
                  child: ClipOval(
                    child: TextButton(
                      onPressed: () {
                        AddFavourite(_country, _imageUrl, true);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return Positioned(
                  top: 0,
                  right: 0,
                  child: ClipOval(
                    child: TextButton(
                      onPressed: () {
                        AddFavourite(_country, _imageUrl, false);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Icon(
                            Icons.favorite_outline,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          SizedBox(
            width: 15,
          ),
        ],
        backgroundColor: Colors.blue[800],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Country')
                .doc(widget.city)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 18,
                        ),
                        CircleAvatar(
                          radius: 20,
                          child: ClipOval(
                            child: Image.network(
                              data['flag'],
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.0),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                data['name'],
                                style: GoogleFonts.changaOne(
                                    fontSize: 32.0, color: Colors.blue[800]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 6.0),
                ],
              );
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Country')
                .doc(widget.city)
                .collection('description')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              final List<DocumentSnapshot> documents = snapshot.data!.docs;
              return Container(
                height: 278,
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Country')
                      .doc(widget.city)
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> countrySnapshot) {
                    if (countrySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (countrySnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${countrySnapshot.error}'));
                    }
                    final countryData = countrySnapshot.data!;
                    final currency = countryData.get('currency');
                    final language = countryData.get('language');
                    final capital = countryData.get('capital');
                    return PageView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          documents.length + 1, // add 1 for the first Container
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          // display the first Container
                          return Container(
                            child: Column(
                              children: [
                                _buildInfoCard(
                                  icon: Icons.monetization_on,
                                  title: 'Currency',
                                  subtitle: currency,
                                ),
                                _buildInfoCard(
                                  icon: Icons.language,
                                  title: 'Language',
                                  subtitle: language,
                                ),
                                _buildInfoCard(
                                  icon: Icons.location_city,
                                  title: 'Capital',
                                  subtitle: capital,
                                ),
                              ],
                            ),
                          );
                        } else {
                          // display the descriptions from the documents list
                          final String des = documents[index - 1].get('des');

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Center(
                              child: Text(
                                des,
                                style: GoogleFonts.chivo(
                                    fontSize: 18.0, color: Colors.blue[800]),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              );
            },
          ),
          SizedBox(
            height: 10,
          ),
          CityList(
            cityName: widget.city,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blue[800],
        ),
        title: Text(
          title,
          style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800]),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}

class CityList extends StatefulWidget {
  final String cityName;

  CityList({required this.cityName});

  @override
  _CityListState createState() => _CityListState();
}

class _CityListState extends State<CityList> {
  void dispose() {
    super.dispose();
  }

  void AddFavourite(
      String city, String imageUrl, bool isFavourite, GeoPoint location) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userRef =
        FirebaseFirestore.instance.collection('Person').doc(currentUser!.uid);
    final favouriteRef = userRef.collection('FavCities').doc(city);

    if (isFavourite) {
      favouriteRef.delete();
      setState(() {
        isFavourite = false;
      });
    } else {
      favouriteRef.set({
        'name': city,
        'image': imageUrl,
        "location": location,
      });
      setState(() {
        isFavourite = true;
      });
    }
  }

  Future<bool> checkIfFavourite(String city) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final favCountriesCollection = FirebaseFirestore.instance
        .collection('Person')
        .doc(uid)
        .collection('FavCities');

    bool isFavourite = false;

    final querySnapshot = await favCountriesCollection.get();
    querySnapshot.docs.forEach((doc) {
      if (doc.id.toString() == city) {
        isFavourite = true;
      }
    });

    return isFavourite;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Country')
          .doc(widget.cityName)
          .collection('Cities')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return SizedBox(
          height: 261,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              var cityDoc = snapshot.data!.docs[index];
              final Future<bool> isFavourite = checkIfFavourite(cityDoc.id);

              return Padding(
                padding: EdgeInsets.all(1),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 240,
                          width: 390,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CityDetailPage(
                                          cityName: cityDoc.id,
                                          imageUrl: cityDoc['image'],
                                          location: cityDoc['location'],
                                        )),
                              );
                            },
                            child: Image.network(
                              cityDoc['image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        FutureBuilder<bool>(
                          future: isFavourite,
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data!) {
                              return Positioned(
                                top: 0,
                                right: 0,
                                child: ClipOval(
                                  child: TextButton(
                                    onPressed: () {
                                      AddFavourite(cityDoc.id, cityDoc['image'],
                                          true, cityDoc["location"]);
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: ClipOval(
                                        child: Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Positioned(
                                top: 0,
                                right: 0,
                                child: ClipOval(
                                  child: TextButton(
                                    onPressed: () {
                                      AddFavourite(cityDoc.id, cityDoc['image'],
                                          false, cityDoc["location"]);
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: ClipOval(
                                        child: Icon(
                                          Icons.favorite_outline,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            color: Colors.black38,
                            child: Text(
                              cityDoc.id,
                              style: GoogleFonts.chivo(
                                  color: Colors.white, fontSize: 25),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
