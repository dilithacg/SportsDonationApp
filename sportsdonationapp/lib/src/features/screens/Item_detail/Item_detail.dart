import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:sportsdonationapp/src/constants/colors.dart';
import 'item_request.dart';

class ItemDetails extends StatefulWidget {
  final String itemName;
  final List<String> itemImages;
  final String uploadedTime;
  final String district;
  final String city;
  final String contactNumber;
  final String description;
  final int itemCount;
  final String donatorName;
  final String itemID;
  final String donatorID;

  const ItemDetails({
    required this.itemName,
    required this.itemImages,
    required this.uploadedTime,
    required this.district,
    required this.city,
    required this.contactNumber,
    required this.description,
    required this.itemCount,
    required this.donatorName,
    required this.itemID,
    required this.donatorID,
  });

  @override
  _ItemDetailsState createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  void requestItem(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemRequest(
          itemName: widget.itemName,
          itemImages: widget.itemImages,
          uploadedTime: widget.uploadedTime,
          district: widget.district,
          city: widget.city,
          contactNumber: widget.contactNumber,
          description: widget.description,
          itemCount: widget.itemCount,
          donatorName: widget.donatorName,
          itemID: widget.itemID,
          donatorID: widget.donatorID,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.parse(widget.uploadedTime);
    String formattedTime = DateFormat('kk:mm').format(dateTime); // Use 'kk' for 24-hour format
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    int differenceInDays = DateTime.now().difference(dateTime).inDays;
    String dayAgo = differenceInDays == 0 ? 'Today' : '$differenceInDays day${differenceInDays == 1 ? '' : 's'} ago';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.sPSecondaryColor,
        title: Text(
          'Item Details',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            CarouselSlider(
              options: CarouselOptions(
                height: 250.0,
                enlargeCenterPage: true,
                autoPlay: false,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 0.8,
              ),
              items: widget.itemImages.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey[300],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          item,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Text(
              widget.itemName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 20),
            Text(
              'Donator Name: ${widget.donatorName}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 6),
            Text(
              'Uploaded: $dayAgo',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 6),
            Text(
              ' $formattedDate at $formattedTime',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 6),
            Text(
              'District: ${widget.district}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 6),
            Text(
              'City: ${widget.city}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 6),

            Text(
              'Description: ${widget.description}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Item Count: ${widget.itemCount}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 120),
            Center(
              child: Container(
                child: ElevatedButton(
                  onPressed: () => requestItem(context),
                  style: ElevatedButton.styleFrom(
                    primary: MyColors.sThColor,
                    onPrimary: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Request Item',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
