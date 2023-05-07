import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CityImageWidget extends StatefulWidget {
  const CityImageWidget({Key? key, required this.cityName}) : super(key: key);

  final String cityName;

  @override
  _CityImageWidgetState createState() => _CityImageWidgetState();
}

class _CityImageWidgetState extends State<CityImageWidget> {
  String? cityImageUrl;
  String? address;

  @override
  void initState() {
    super.initState();
    getCityData();
  }

  Future<void> getCityData() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('Country').get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot
        in querySnapshot.docs) {
      QuerySnapshot<Map<String, dynamic>> citySnapshot =
          await docSnapshot.reference.collection('Cities').get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> cityDocSnapshot
          in citySnapshot.docs) {
        Map<String, dynamic> cityData = cityDocSnapshot.data();

        if (cityData['name'] == widget.cityName) {
          setState(() {
            cityImageUrl = cityData['image'];
          });
          break;
        }
      }

      if (cityImageUrl != null) {
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cityImageUrl == null) {
      return const CircularProgressIndicator();
    }

    return Column(
      children: [
        Image.network(cityImageUrl!),
        const SizedBox(height: 8),
      ],
    );
  }
}
