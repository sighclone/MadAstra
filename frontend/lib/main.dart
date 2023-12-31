import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
// import 'package:frontend/iss.dart';
import 'package:frontend/star_background.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  debugPrint("ON");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

// ignore: camel_case_types
class apod extends StatelessWidget {
  const apod({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Future<Map<String, dynamic>> fetchApodData() async {
      final response = await http.get(
          Uri.parse('https://solar-geek-api.onrender.com/v1/getApodApiImage'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load data');
      }
    }

// ignore: no_leading_underscores_for_local_identifiers
    _launchURL() async {
      final Uri url = Uri.parse('https://apod.nasa.gov/apod/');
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 52, 52, 52),
      appBar: AppBar(
          centerTitle: true, title: const Text("Astronomy Pic of the Day!")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchApodData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!['Data'];
            return SingleChildScrollView(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    // ignore: prefer_interpolation_to_compose_strings
                    "Image of " + data['date'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0),
                  ),
                  const SizedBox(height: 10.0),
                  Image.network(data['url']),
                  const SizedBox(height: 10.0),
                  Text(
                    'Copyright: ${data['copyright']}',
                    style: const TextStyle(
                        color: Colors.white, fontStyle: FontStyle.italic),
                  ),
                  Text(
                    data['explanation'],
                    style: const TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                  const SizedBox(height: 10.0),
                  TextButton(
                    onPressed: _launchURL,
                    child: const Text("Find out more at NASA APOD."),
                  ),
                ],
              ),
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: myhome());
  }
}

// ignore: camel_case_types
class myhome extends StatelessWidget {
  const myhome({Key? key}) : super(key: key);
  Future<String> getCurrentCityAndPrint() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // Check for location permissions
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return "Location permission denied";
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // GEOCODE!!!
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      String city = place.locality ?? "Unknown"; // :/ null safety

      return city;
    } catch (error) {
      return "Error getting current city: $error";
    }
  }

  Future<Map<String, dynamic>> fetchWeatherData() async {
    final mycity = await getCurrentCityAndPrint();
    final response = await http.get(Uri.parse(
        'https://solar-geek-api.onrender.com/v1/performWeatherAnalysis?city=$mycity'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint("CITY IS: $mycity");
      data['city'] = mycity;
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 52, 52, 52),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const credits(),
                ),
              );
            },
          ),
          title: const Text('MadAstra'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.satellite_alt),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const iss(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const apod(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.landscape),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const apod(),
                  ),
                );
              },
            ),
          ],
          // bottom: ,
        ),
        body: Stack(children: [
          const StarBackground(),
          Column(
            children: [
              FutureBuilder<String>(
                future: getCurrentCityAndPrint(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    String city = snapshot.data!;
                    return Text(
                        "Your current location is identified as: $city");
                  } else if (snapshot.hasError) {
                    return Text("Error getting city: ${snapshot.error}");
                  } else {
                    // Found a gimmick to keepalive the star animation
                    return const LinearProgressIndicator(
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ); // this is FAKE! loads forever <3
                  }
                },
              ),
              FutureBuilder<Map<String, dynamic>>(
                future: fetchWeatherData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final analysis = snapshot.data!['Analysis'];
                    final data = snapshot.data!['Data'];
                    final city = snapshot.data!['city'];
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "‎ Lat: ${data['coord']['lat']}   Lon: ${data['coord']['lon']}   Location: $city ‎ ",
                            style: const TextStyle(
                              backgroundColor: Color.fromARGB(255, 52, 52, 52),
                              color: Colors.white,
                              fontWeight: FontWeight.normal,
                              fontSize: 12.0,
                            ),
                          ),
                          const SizedBox(height: 50.0),
                          const Text(
                            "SUMMARY",
                            style: TextStyle(
                                backgroundColor:
                                    Color.fromARGB(255, 52, 52, 52),
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0),
                          ),
                          Text(
                            "$analysis",
                            style: const TextStyle(
                                backgroundColor:
                                    Color.fromARGB(255, 52, 52, 52),
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0),
                          ),
                          const SizedBox(height: 50.0),
                          const Text(
                            "STATS",
                            style: TextStyle(
                                backgroundColor:
                                    Color.fromARGB(255, 52, 52, 52),
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0),
                          ),
                          Text(
                            "Temperature: ${data['main']['temp']}\nPressure: ${data['main']['pressure']}\nHumidity: ${data['main']['humidity']}\nVisibility: ${data['visibility']}",
                            style: const TextStyle(
                                backgroundColor:
                                    Color.fromARGB(255, 52, 52, 52),
                                //backgroundColor: Colors.black,
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 18.0),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ]));
  }
}

class StarBackground extends StatefulWidget {
  const StarBackground({Key? key}) : super(key: key);

  @override
  State<StarBackground> createState() => _StarBackgroundState();
}

class _StarBackgroundState extends State<StarBackground>
    with TickerProviderStateMixin {
  // Use TickerProvider for animation
  late StarBackgroundPainter painter;
  late Timer timer; // Use a Timer for repainting

  @override
  void initState() {
    super.initState();
    painter = StarBackgroundPainter();
    _startAnimation();
  }

  void _startAnimation() {
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {}); // Trigger repaint
    });
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel timer on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: painter,
      child: Container(),
    );
  }
}

// ignore: camel_case_types
class iss extends StatelessWidget {
  const iss({Key? key}) : super(key: key);
  Future<Map<String, dynamic>> fetchIssData() async {
    final response = await http.get(
        Uri.parse('https://solar-geek-api.onrender.com/v1/getIssLocation'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    launchMyURL(lat, lon) async {
      fetchIssData();
      final Uri url =
          Uri.parse('http://maps.google.com/maps?z=11&t=m&q=loc:$lat+$lon');

      //http://maps.google.com/maps?z=11&t=m&q=loc:$lat+$lon
      debugPrint(url.toString());
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live ISS location"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchIssData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final message = snapshot.data!['Message'];
            final String lat = message['latitude'].toString();
            final String lon = message['longitude'].toString();
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "\n\nLat: $lat   Lon: $lon\n",
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextButton(
                    onPressed: () async {
                      try {
                        await launchMyURL(lat, lon);
                      } catch (err) {
                        debugPrint('... Unable to launch URL');
                      }
                    },
                    child: const Text("Click to view in Google Maps!"),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

// ignore: camel_case_types
class credits extends StatelessWidget {
  const credits({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("credits opened");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Credits"),
      ),
      body: const Center(
        child: Text(
            "Made by Abhinav Sadhu\nuses Solar Geek API by Sankalp Pandey"),
      ),
    );
  }
}
