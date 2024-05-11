import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'colors.dart';

void main() {
  runApp(MaterialApp(
    title: 'Approved Requests',
    home: Approved(),
  ));
}

class Approved extends StatefulWidget {
  const Approved({Key? key}) : super(key: key);

  @override
  State<Approved> createState() => _ApprovedState();
}

class _ApprovedState extends State<Approved> {
  List<String> completedRequests = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approved Requests'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('item_requests')
            .where('approved', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No approved requests found.'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              List<String> itemImages = List<String>.from(document['itemImages']);
              String firstImage = itemImages.isNotEmpty ? itemImages[0] : '';
              String evidenceImageUrl = document['evidenceImageUrl'];

              bool isCompleted = completedRequests.contains(document.id);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Item Details',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text('Name: ${document['itemName']}'),
                              Text('Donator Name: ${document['donatorName']}'),
                              Text('Uploaded: ${document['uploadedTime']}'),
                              Text('District: ${document['district']}'),
                              Text('City: ${document['city']}'),
                              Text('Contact Number: ${document['contactNumber']}'),
                              Text('Description: ${document['description']}'),
                              Text('Available Item Count: ${document['itemCount']}'),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  _navigateToFullScreenImage(context, firstImage);
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Item Image',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request Details',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Text('Requestor Name: ${document['ReqName']}'),
                              Text('Uploaded : ${document['ReqTime']}'),
                              Text('Requirement: ${document['requirement']}'),
                              Text('NIC Number: ${document['nicNumber']}'),
                              Text('School or Club Name: ${document['schoolOrClubName']}'),
                              Text('City: ${document['RCity']}'),
                              Text('address: ${document['address']}'),
                              Text('Contact Number: ${document['RContactNumber']}'),
                              Text('Requested Item Count: ${document['requestedItemCount']}'),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  _navigateToFullScreenImage(context, evidenceImageUrl);
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Evidence Image',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    if (evidenceImageUrl.isNotEmpty)
                                      Image.network(
                                        evidenceImageUrl,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Text('Error loading image');
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),

                        // Complete Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.sThColor,
                          ),
                          onPressed: () {
                            // Update Firestore document
                            FirebaseFirestore.instance
                                .collection('item_requests')
                                .doc(document.id) // Assuming 'id' is the document ID
                                .update({'completed': true})
                                .then((_) {
                              print('Document marked as completed successfully');
                              setState(() {
                                completedRequests.add(document.id);
                              });
                            }).catchError((error) {
                              print('Error marking document as completed: $error');
                            });
                          },

                          child: Text(isCompleted ? 'Completed' : 'Complete'),

                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToFullScreenImage(BuildContext context, String imageUrl) {
    // Implement your navigation logic here
    // For example, navigate to a full-screen image view
  }
}
