import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wanderlust/main.dart';

class CountryCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SizedBox(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('Country').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final List<DocumentSnapshot> documents = snapshot.data!.docs;
              final int pageCount = (documents.length / 4).ceil();
              return PageView.builder(
                itemCount: pageCount,
                itemBuilder: (BuildContext context, int pageIndex) {
                  final int startIndex = pageIndex * 4;
                  final int endIndex = startIndex + 4;
                  final List<DocumentSnapshot> pageDocuments =
                      documents.sublist(
                          startIndex,
                          endIndex < documents.length
                              ? endIndex
                              : documents.length);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(pageDocuments.length,
                                (int index) {
                              final String city =
                                  pageDocuments[index].get('name');
                              final String imageUrl =
                                  pageDocuments[index].get('image');
                              final String ShortCut = pageDocuments[index].id;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CityScreen(city: ShortCut),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Stack(
                                        children: [
                                          Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            height: double.infinity,
                                            width: double.infinity,
                                          ),
                                          Positioned(
                                            bottom: 5,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
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
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        SizedBox(height: 8.0),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
