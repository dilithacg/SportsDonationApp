import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web_admin/Screens/updates.dart';
import 'Category.dart';
import 'addupdate.dart';
import 'approved.dart';
import 'coaches.dart';
import 'colors.dart';
import 'item_requests.dart';
import 'login.dart';
import 'main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalItemCount = 0;
  Map<String, int> categoryCounts = {};

  @override
  void initState() {
    super.initState();
    fetchItemCounts();
  }

  Future<void> fetchItemCounts() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('items')
          .where('approved', isEqualTo: true)
          .get();

      int totalCount = 0;
      Map<String, int> counts = {};

      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String sportsCategory = data['sportsCategory'];

        totalCount++;
        counts[sportsCategory] = (counts[sportsCategory] ?? 0) + 1;
      });

      setState(() {
        totalItemCount = totalCount;
        categoryCounts = counts;
      });
    } catch (e) {
      print('Error fetching item counts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Interface',
          style: TextStyle(
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: MyColors.sPSecondaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.logout,color: Colors.black,),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminLoginScreen(),
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var category in availableCategories)
                  ElevatedButton(
                    onPressed: () {
                      _navigateToCategoryScreen(context, category);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: category.color,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    ),
                    child: Text(
                      category.title,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Total Available Items: $totalItemCount',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: categoryCounts.length,
                itemBuilder: (context, index) {
                  String category = categoryCounts.keys.elementAt(index);
                  int itemCount = categoryCounts.values.elementAt(index);
                  return ListTile(
                    title: Text('$category: $itemCount'),

                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCategoryScreen(BuildContext context, Category category) {
    // Use a switch statement or if-else to determine which screen to navigate to
    switch (category.id) {
      case 'c1':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminScreen()),
        );
        break;
      case 'c2':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminItemRequestScreen()),
        );
        break;
      case 'c3':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Approved()),
        );
        break;
      case 'c4':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ImageUploader()),
        );
        break;
      case 'c5':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddTextToFirestore()),
        );

    // Navigate to FootballItemsList

    }
  }
}
