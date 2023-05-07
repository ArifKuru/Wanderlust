import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

const String API_KEY =
    "*";

class Restaurant {
  final String name;
  final String address;
  final String phone;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String category;
  final String price;
  final String hours;
  final String menu;
  final String website;

  Restaurant({
    required this.name,
    required this.address,
    required this.phone,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.price,
    required this.hours,
    required this.menu,
    required this.website,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      name: json['name'] ?? 'Not available',
      address: json['location']['display_address'] != null
          ? json['location']['display_address'].join(', ')
          : 'Not available',
      phone: json['phone'] ?? 'Not available',
      rating: json['rating'] != null ? json['rating'].toDouble() : 0.0,
      reviewCount: json['review_count'] ?? 0,
      imageUrl: json['image_url'] ?? 'Not available',
      latitude: json['coordinates']['latitude'] != null
          ? json['coordinates']['latitude'].toDouble()
          : 0.0,
      longitude: json['coordinates']['longitude'] != null
          ? json['coordinates']['longitude'].toDouble()
          : 0.0,
      category: json['categories'] != null && json['categories'].isNotEmpty
          ? json['categories'][0]['title'] ?? 'Not available'
          : 'Not available',
      price: json['price'] ?? 'Not available',
      hours: json['hours'] != null && json['hours'].isNotEmpty
          ? json['hours'][0]['open'] != null &&
                  json['hours'][0]['open'].isNotEmpty
              ? json['hours'][0]['open'][0]['start'] != null &&
                      json['hours'][0]['open'][0]['end'] != null
                  ? json['hours'][0]['open'][0]['start'] +
                      ' - ' +
                      json['hours'][0]['open'][0]['end']
                  : 'Not available'
              : 'Not available'
          : 'Not available',
      menu: json['menu'] != null
          ? json['menu']['url'] ?? 'Not available'
          : 'Not available',
      website: json['url'] ?? 'Not available',
    );
  }
}

class RestaurantList extends StatefulWidget {
  final dynamic position;
  RestaurantList({required this.position});
  @override
  _RestaurantListState createState() => _RestaurantListState();
}

class _RestaurantListState extends State<RestaurantList> {
  List<Restaurant> _restaurants = [];

  Future<void> _fetchRestaurants() async {
    final response = await http.get(
        Uri.parse(
            "https://api.yelp.com/v3/businesses/search?latitude=${widget.position.latitude}&longitude=${widget.position.longitude}"),
        headers: {"Authorization": "Bearer $API_KEY"});
    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      setState(() {
        _restaurants = List.from(jsonBody['businesses'])
            .map((json) => Restaurant.fromJson(json))
            .toList();
      });
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 262,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _restaurants.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(1.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantDetail(
                              restaurantId: _restaurants[index],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 240,
                        width: 390,
                        child: _restaurants[index].imageUrl.isNotEmpty
                            ? Image.network(
                                _restaurants[index].imageUrl,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                'https://t4.ftcdn.net/jpg/02/75/70/03/360_F_275700347_09reCCwb7JBxTKiYQXsyri4riMKaHbj8.jpg',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _restaurants[index].name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.yellow),
                                SizedBox(width: 5),
                                Text(
                                  '${_restaurants[index].rating}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text(
                              _restaurants[index].phone,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
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
  }
}

/*ListTile(
title: Text(_restaurants[index].name),
subtitle: Text('Rating: ${_restaurants[index].rating}'),
leading: Image.network(_restaurants[index].imageUrl),
trailing: Text(_restaurants[index].phone),
)*/
class RestaurantDetail extends StatefulWidget {
  final dynamic restaurantId;

  RestaurantDetail({required this.restaurantId});

  @override
  _RestaurantDetailState createState() => _RestaurantDetailState();
}

class _RestaurantDetailState extends State<RestaurantDetail> {
  late Future<Restaurant> _futureRestaurant;

  Future<Restaurant> _fetchRestaurantDetails() async {
    return widget.restaurantId;
  }

  @override
  void initState() {
    super.initState();
    _futureRestaurant = _fetchRestaurantDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Detail'),
      ),
      body: FutureBuilder<Restaurant>(
        future: _futureRestaurant,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final restaurant = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    restaurant.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    restaurant.name,
                    style:
                        TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.location_on),
                      SizedBox(width: 8.0),
                      Text(restaurant.address),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.star),
                      SizedBox(width: 8.0),
                      Text(
                          '${restaurant.rating} (${restaurant.reviewCount} reviews)'),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    restaurant.category,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    restaurant.price,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    restaurant.hours,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      launch(restaurant.menu);
                    },
                    child: Text('View Menu'),
                  ),
                  SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      launch(restaurant.website);
                    },
                    child: Text('Visit Website'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
