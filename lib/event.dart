import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Event {
  final String name;
  final String description;
  final String url;
  final String imageUrl;
  final String startDate;
  final String endDate;
  final String venueName;
  final String address;

  Event({
    required this.name,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.venueName,
    required this.address,
  });
}

Future<List<Event>> fetchEvents() async {
  final url =
      'https://www.eventbriteapi.com/v3/events/search/?location.address=istanbul&location.within=50km&expand=venue';

  final response = await http.get(
    Uri.parse(url),
    headers: {'Authorization': 'Bearer PSMOXB7AAPZ6HUXVWVKX'},
  );

  final jsonData = jsonDecode(response.body);

  final eventsData = (jsonData['events'] as List<dynamic>?) ?? [];

  final events = eventsData.map((eventData) {
    final name = eventData['name']['text'] as String;
    final description = eventData['description']['text'] as String;
    final url = eventData['url'] as String;
    final imageUrl =
        eventData['logo'] != null ? eventData['logo']['url'] as String : '';
    final startDate = eventData['start']['local'] as String;
    final endDate = eventData['end']['local'] as String;
    final venueName = eventData['venue']['name'] as String;
    final address =
        eventData['venue']['address']['localized_address_display'] as String;

    return Event(
      name: name,
      description: description,
      url: url,
      imageUrl: imageUrl,
      startDate: startDate,
      endDate: endDate,
      venueName: venueName,
      address: address,
    );
  }).toList();

  return events;
}

class eventapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventbrite Events',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Event>> _events;

  @override
  void initState() {
    super.initState();
    _events = fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventbrite Events'),
      ),
      body: Center(
        child: FutureBuilder<List<Event>>(
          future: _events,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final events = snapshot.data!;
              return ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return ListTile(
                    leading: Image.network(event.imageUrl),
                    title: Text(event.name),
                    subtitle: Text(event.description),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventDetailsPage(event: event),
                        ),
                      );
                    },
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

class EventDetailsPage extends StatelessWidget {
  final Event event;

  const EventDetailsPage({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(event.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(event.imageUrl),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Date: ${event.startDate}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'End Date: ${event.endDate}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Venue Name: ${event.venueName}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Address: ${event.address}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Description: ${event.description}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
