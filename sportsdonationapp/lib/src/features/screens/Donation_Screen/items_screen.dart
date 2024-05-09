import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportsdonationapp/src/constants/colors.dart';
import '../Item_detail/Item_detail.dart';
import 'package:intl/intl.dart';

class ItemsList extends StatefulWidget {
  const ItemsList({Key? key}) : super(key: key);

  @override
  _ItemsListState createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  List<ItemData> items = [];
  List<String> categories = [
    'All',
    'Cricket',
    'Football',
    'Rugby',
    'Netball',
    'Volleyball',
    'Other'
  ];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // Fetch data from Firestore when the widget is initialized
    fetchDataFromFirestore();
  }

  Future<void> fetchDataFromFirestore() async {
    try {
      QuerySnapshot querySnapshot;

      if (selectedCategory == 'All') {
        querySnapshot = await FirebaseFirestore.instance
            .collection('items')
            .where('approved', isEqualTo: true)
            .orderBy('uploadedTime', descending: true)
            .get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection('items')
            .where('sportsCategory', isEqualTo: selectedCategory)
            .where('approved', isEqualTo: true)
            .orderBy('uploadedTime', descending: true)
            .get();
      }

      List<ItemData> fetchedItems = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ItemData(
          itemName: data['itemName'] ?? 'Item',
          itemID: doc.id,
          itemImages: List<String>.from(data['itemImages'] ?? []),
          uploadedTime: data['uploadedTime'] ?? '',
          district: data['district'] ?? '',
          city: data['city'] ?? '',
          donatorName: data['donatorName'] ?? '',
          contactNumber: data['contactNumber'] ?? '',
          description: data['description'] ?? '',
          approved: data['approved'] ?? false,
          itemCount: data['itemCount'] ?? 0,
          donatorID: data['donatorID'] ?? '',
        );
      }).toList();

      setState(() {
        items = fetchedItems;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Items List'),
        backgroundColor: MyColors.sPSecondaryColor,
        centerTitle: true,
        actions: [
          DropdownButton<String>(
            value: selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue!;
                fetchDataFromFirestore();
              });
            },
            items: categories.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Item(
              itemName: items[index].itemName,
              itemImages: items[index].itemImages,
              uploadedTime: items[index].uploadedTime,
              district: items[index].district,
              city: items[index].city,
              contactNumber: items[index].contactNumber,
              description: items[index].description,
              itemCount: items[index].itemCount,
              donatorName: items[index].donatorName,
              donatorID: items[index].donatorID,
              itemID: items[index].itemID,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemDetails(
                      itemName: items[index].itemName,
                      itemImages: items[index].itemImages,
                      uploadedTime: items[index].uploadedTime,
                      district: items[index].district,
                      city: items[index].city,
                      contactNumber: items[index].contactNumber,
                      description: items[index].description,
                      itemCount: items[index].itemCount,
                      donatorName: items[index].donatorName,
                      donatorID: items[index].donatorID,
                      itemID: items[index].itemID,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class Item extends StatelessWidget {
  final String itemName;
  final String itemID;
  final List<String> itemImages;
  final String uploadedTime;
  final String contactNumber;
  final String description;
  final VoidCallback onTap;
  final int itemCount;
  final String district;
  final String city;
  final String donatorName;
  final String donatorID;

  const Item({
    required this.itemName,
    required this.itemID,
    required this.itemImages,
    required this.uploadedTime,
    required this.contactNumber,
    required this.description,
    required this.onTap,
    required this.itemCount,
    required this.district,
    required this.city,
    required this.donatorName,
    required this.donatorID,
  });

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.parse(uploadedTime);
    String formattedTime = DateFormat('KK:mm').format(dateTime);
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    int differenceInDays = DateTime.now().difference(dateTime).inDays;
    String dayAgo = differenceInDays == 0 ? 'Today' : '$differenceInDays day${differenceInDays == 1 ? '' : 's'} ago';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: itemImages.isNotEmpty
                    ? Image.network(
                  itemImages.isNotEmpty ? itemImages[0] : 'gs://sportsitemdonationp.appspot.com/imageFile',
                  fit: BoxFit.cover,
                  height: 150,
                  width: 180,
                )
                    : const Icon(Icons.image),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemName,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    Text(
                      'Uploaded: $dayAgo, $formattedDate at $formattedTime',
                      style: const TextStyle(color: Colors.black45),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemData {
  String itemName;
  List<String> itemImages;
  String uploadedTime;
  String district;
  String city;
  String contactNumber;
  String description;
  bool approved;
  int itemCount;
  String donatorName;
  String donatorID;
  String itemID;

  ItemData({
    required this.itemName,
    required this.itemImages,
    required this.uploadedTime,
    required this.district,
    required this.city,
    required this.contactNumber,
    required this.description,
    required this.approved,
    required this.itemCount,
    required this.donatorName,
    required this.donatorID,
    required this.itemID,
  });
}
