import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/colors.dart';

class Coach {
  final String id; // Add ID field
  final String name;
  final String sport;
  final String price;
  final String district;
  final String city;
  final String details;
  final String phoneNumber;
  final String imageUrl;

  Coach({
    required this.id,
    required this.name,
    required this.sport,
    required this.price,
    required this.district,
    required this.city,
    required this.details,
    required this.phoneNumber,
    required this.imageUrl,
  });
}

class CoachesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coaches'),
        backgroundColor: MyColors.sPSecondaryColor,
      ),
      body: CoachesGrid(),
    );
  }
}

class CoachesGrid extends StatefulWidget {
  @override
  _CoachesGridState createState() => _CoachesGridState();
}

class _CoachesGridState extends State<CoachesGrid> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Coach>>(
      future: getCoachesFromFirestore(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        List<Coach> coaches = snapshot.data!;
        return ListView.builder(
          itemCount: coaches.length,
          itemBuilder: (context, index) {
            Coach coach = coaches[index];
            return GestureDetector(
              onTap: () {
                // Handle coach selection or navigation to coach details
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Card(
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coach.name,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(height: 5),
                            Text('Sport: ${coach.sport}'),
                            Text('Price: ${coach.price}'),
                            Text('District: ${coach.district}'),
                            Text('City: ${coach.city}'),
                            Text('Details: ${coach.details}'),
                            GestureDetector(
                              onTap: () {
                                _launchPhoneCall(coach.phoneNumber);
                              },
                              child: Icon(Icons.phone, color: Colors.green),
                            ),
                            FutureBuilder<double>(
                              future: getAverageRating(coach.id),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                double averageRating = snapshot.data ?? 0.0;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RatingBar.builder(
                                      initialRating: averageRating,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: false,
                                      itemCount: 5,
                                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                      itemBuilder: (context, _) => Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {
                                        _updateRating(coach, rating);
                                      },
                                    ),
                                    Text('Average Rating: ${averageRating.toStringAsFixed(1)}'),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Image.network(
                        coach.imageUrl,
                        width: double.infinity,
                        height: 200, // Adjust image height as needed
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _updateRating(Coach coach, double rating) async {
    try {
      // Add a new rating document to the 'ratings' collection
      await FirebaseFirestore.instance.collection('ratings').add({
        'coachId': coach.id,
        'userId': 'userID', // You need to replace 'userID' with the actual user ID
        'rating': rating,
      });
      print('Coach: ${coach.name}, Rating: $rating');
    } catch (e) {
      print('Error updating rating: $e');
    }
  }

  Future<double> getAverageRating(String coachId) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .where('coachId', isEqualTo: coachId)
        .get();

    if (snapshot.docs.isEmpty) {
      return 0; // No ratings yet
    }

    // Calculate the average rating
    double totalRating = snapshot.docs.fold(0, (sum, doc) => sum + doc['rating']);
    return totalRating / snapshot.docs.length;
  }

  Future<List<Coach>> getCoachesFromFirestore() async {
    List<Coach> coaches = [];
    QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('coaches').get();

    snapshot.docs.forEach((doc) {
      coaches.add(Coach(
        id: doc.id, // Assigning Firestore document ID to Coach's id field
        name: doc['name'],
        sport: doc['sport'],
        price: doc['price'],
        district: doc['district'],
        city: doc['city'],
        details: doc['detail'],
        phoneNumber: doc['phone_number'],
        imageUrl: doc['image_url'],
      ));
    });

    return coaches;
  }

  void _launchPhoneCall(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

