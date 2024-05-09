import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Stream<QuerySnapshot> _pendingRequestsStream;

  @override
  void initState() {
    super.initState();
    _pendingRequestsStream =
        FirebaseFirestore.instance.collection('items').where(
            'approved', isEqualTo: false).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donate Requests'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _pendingRequestsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                List<String> itemImages = List<String>.from(
                    document['itemImages']);
                String firstImage = itemImages.isNotEmpty ? itemImages[0] : '';
                GeoPoint? location = document['location'];
                String locationString = location != null
                    ? 'Location: (${location.latitude}, ${location.longitude})'
                    : 'Location: Not available';

                Widget locationWidget = GestureDetector(
                  onTap: () {
                    if (location != null) {
                      launch(
                          'https://www.google.com/maps/search/?api=1&query=${location
                              .latitude},${location.longitude}');
                    }
                  },
                  child: Text(
                    locationString,
                    style: TextStyle(
                      color: location != null ? Colors.blue : Colors.grey,
                      // Change color based on availability
                      decoration: location != null
                          ? TextDecoration.underline
                          : TextDecoration.none, // Underline if available
                    ),
                  ),
                );

                // Fetch donator name from Firestore users collection
                String donatorName = document['donatorName'] ?? 'Anonymous';

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 3,
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document['itemName'],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('Donator: $donatorName'),
                          // Display donator name for admin
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text('Uploaded: ${document['uploadedTime']}'),
                          SizedBox(height: 8),
                          Text(
                              'Sports Category: ${document['sportsCategory']}'),
                          SizedBox(height: 8),
                          Text('District: ${document['district']}'),
                          SizedBox(height: 8),
                          Text('City: ${document['city']}'),
                          SizedBox(height: 8),
                          Text('Contact Number: ${document['contactNumber']}'),
                          SizedBox(height: 8),
                          Text('Description: ${document['description']}'),
                          SizedBox(height: 8),
                          Text('Item Count: ${document['itemCount']}'),
                          SizedBox(height: 8),
                          locationWidget,
                          SizedBox(height: 8),
                          if (firstImage.isNotEmpty)
                            Image.network(
                              firstImage,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text('Error loading image');
                              },
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () => _approveRequest(document.id),
                                style: ElevatedButton.styleFrom(
                                  elevation: 1,
                                  backgroundColor: Colors
                                      .green, // Set background color here
                                ),
                                child: const Text(
                                  'Approve',
                                  style: TextStyle(
                                    color: Colors.white, // Set text color here
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _rejectRequest(document.id),
                                style: ElevatedButton.styleFrom(
                                  elevation: 1,
                                  backgroundColor: Colors
                                      .red, // Set background color here
                                ),
                                child: const Text(
                                  'Reject',
                                  style: TextStyle(
                                    color: Colors.white, // Set text color here
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return Center(child: Text('No pending requests.'));
        },
      ),
    );
  }

  void _approveRequest(String documentId) {
    FirebaseFirestore.instance.collection('items').doc(documentId).update({
      'approved': true,
    }).then((_) {
      print('Request approved successfully!');
    }).catchError((error) {
      print('Error approving request: $error');
    });
  }

  void _rejectRequest(String documentId) {
    FirebaseFirestore.instance.collection('items').doc(documentId)
        .delete()
        .then((_) {
      print('Request rejected successfully!');
    }).catchError((error) {
      print('Error rejecting request: $error');
    });
  }
}
