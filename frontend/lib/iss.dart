import 'dart:convert';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class iss extends StatelessWidget {
  const iss({Key? key}) : super(key: key);

  get http => null;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live ISS location"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchIssData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final message = snapshot.data!['Message'];
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "\n\nLat: ${message['latitude']}   Lon: ${message['longitude']}\n",
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12.0,
                    ),
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

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class Iss extends StatefulWidget {
//   const Iss({Key? key}) : super(key: key);

//   @override
//   _IssState createState() => _IssState();
// }

// class _IssState extends State<Iss> {
//   LatLng? issPosition;
//   GoogleMapController? mapController;

//   Future<void> fetchIssData() async {
//     final response = await http.get(
//       Uri.parse('https://solar-geek-api.onrender.com/v1/getIssLocation'),
//     );
//     if (response.statusCode == 200) {
//       final message = jsonDecode(response.body) as Map<String, dynamic>;
//       issPosition = LatLng(
//           message['message']['latitude'], message['message']['longitude']);
//       setState(() {});

//       // Move the map camera to the ISS position
//       if (mapController != null) {
//         mapController!.animateCamera(
//           CameraUpdate.newCameraPosition(
//             CameraPosition(target: issPosition!, zoom: 5),
//           ),
//         );
//       }
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchIssData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Live ISS location"),
//       ),
//       body: issPosition == null
//           ? const Center(child: CircularProgressIndicator())
//           : GoogleMap(
//               initialCameraPosition:
//                   CameraPosition(target: issPosition!, zoom: 5),
//               onMapCreated: (controller) => mapController = controller,
//               markers: {
//                 Marker(markerId: const MarkerId('iss'), position: issPosition!),
//               },
//             ),
//     );
//   }
// }
