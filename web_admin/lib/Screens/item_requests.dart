import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';

class AdminItemRequestScreen extends StatefulWidget {
  const AdminItemRequestScreen({Key? key}) : super(key: key);

  @override
  _AdminItemRequestScreenState createState() => _AdminItemRequestScreenState();
}

class _AdminItemRequestScreenState extends State<AdminItemRequestScreen> {
  late Stream<QuerySnapshot> _pendingRequestsStream;

  @override
  void initState() {
    super.initState();
    _pendingRequestsStream = FirebaseFirestore.instance
        .collection('item_requests')
        .where('approved', isEqualTo: false)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Item Requests Approval'),
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
                List<String> itemImages = List<String>.from(document['itemImages']);
                String firstImage = itemImages.isNotEmpty ? itemImages[0] : '';
                String evidenceImageUrl = document['evidenceImageUrl'];
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _approveRequest(document.reference, document['requestedItemCount']),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      child: const Text('Approve'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _rejectRequest(document.reference),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text('Reject'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

  void _approveRequest(DocumentReference requestRef, int requestedCount) {
    requestRef.get().then((snapshot) {
      int availableItemCount = snapshot['itemCount'];
      if (availableItemCount >= requestedCount) {
        int updatedCount = availableItemCount - requestedCount;
        // Update item count only if the request is approved
        int finalCount = snapshot['approved'] ? updatedCount : availableItemCount;
        requestRef.update({
          'approved': true,
          'itemCount': finalCount, // Update the available item count
        }).then((_) {
          // Now update the item count in the items collection
          String itemId = snapshot['itemID'];
          FirebaseFirestore.instance.collection('items').doc(itemId).get().then((itemSnapshot) {
            int currentItemItemCount = itemSnapshot['itemCount'];
            int newItemCount = currentItemItemCount - requestedCount;
            // Update the item count in the items collection
            FirebaseFirestore.instance.collection('items').doc(itemId).update({
              'itemCount': newItemCount,
            }).then((_) {
              print('Item count updated successfully!');
            }).catchError((error) {
              print('Error updating item count: $error');
            });
          }).catchError((error) {
            print('Error fetching item document: $error');
          });
          print('Request approved successfully!');
        }).catchError((error) {
          print('Error approving request: $error');
        });
      } else {
        print('Error: Insufficient available items.');
      }
    }).catchError((error) {
      print('Error getting document: $error');
    });
  }


  void _rejectRequest(DocumentReference requestRef) {
    requestRef.delete().then((_) {
      print('Request rejected successfully!');
    }).catchError((error) {
      print('Error rejecting request: $error');
    });
  }

  void _navigateToFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
          ),
        ),
      ),
    );
  }
}
