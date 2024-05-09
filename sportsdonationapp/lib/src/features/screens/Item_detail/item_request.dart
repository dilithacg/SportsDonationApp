import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemRequest extends StatefulWidget {
  final String itemName;
  final List<String> itemImages;
  final String uploadedTime;
  final String district;
  final String city;
  final String contactNumber;
  final String description;
  final int itemCount; // Available item count
  final String donatorName;
  final String itemID;
  final String donatorID;

  const ItemRequest({
    Key? key,
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
  }) : super(key: key);

  @override
  _ItemRequestState createState() => _ItemRequestState();
}

class _ItemRequestState extends State<ItemRequest> {
  int requestedItemCount = 0;
  File? _selectedImage; // Store the selected image file
  TextEditingController requirementController = TextEditingController();
  TextEditingController nicController = TextEditingController();
  TextEditingController schoolClubNameController = TextEditingController();
  TextEditingController reqCityController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController reqContactNumberController = TextEditingController();

  String? ReqName;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    retrieveReqName();
  }

  Future<void> retrieveReqName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (userSnapshot.exists) {
        setState(() {
          ReqName = userSnapshot['name'];
        });
      }
    }
  }

  Future<void> _submitRequest() async {
    String reqTime = DateTime.now().millisecondsSinceEpoch.toString();
    // Upload data to Firebase
    try {
      // Retrieve requester's name and ID
      await retrieveReqName();
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String requestorID = currentUser.uid;

        String imageUrl = '';
        if (_selectedImage != null) {
          imageUrl = await _uploadImageToStorage();
        }

        FirebaseFirestore.instance.collection('item_requests').add({
          'itemName': widget.itemName,
          'donatorName': widget.donatorName,
          'ReqName': ReqName ?? 'Anonymous',
          'ReqTime': reqTime,
          'itemImages': widget.itemImages,
          'uploadedTime': widget.uploadedTime,
          'district': widget.district,
          'city': widget.city,
          'contactNumber': widget.contactNumber,
          'description': widget.description,
          'itemCount': widget.itemCount,
          'requestedItemCount': requestedItemCount,
          'requirement': requirementController.text,
          'nicNumber': nicController.text,
          'schoolOrClubName': schoolClubNameController.text,
          'RCity': reqCityController.text,
          'address': addressController.text,
          'RContactNumber': reqContactNumberController.text,
          'evidenceImageUrl': imageUrl,
          'approved': false, // Initially set to false, pending admin approval
          'itemID': widget.itemID,
          'donatorID': widget.donatorID,
          'requestorID': requestorID, // Store current user ID as requestorID
        });

        // Show success message or navigate to success screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request submitted successfully')),
        );
      } else {
        // Handle case where currentUser is null
        print('Current user is null');
      }
    } catch (e) {
      // Handle error
      print('Error submitting request: $e');
    }
  }

  Future<String> _uploadImageToStorage() async {
    try {
      // Generate a unique file name using timestamp
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageRef = FirebaseStorage.instance.ref().child('requested_images/$fileName.jpg');
      await storageRef.putFile(_selectedImage!);
      final String imageUrl = await storageRef.getDownloadURL();
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Request'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Upload Evidence Image'),
            ),
            SizedBox(height: 16),
            _selectedImage != null
                ? Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                ),
              ),
            )
                : SizedBox(), // Display selected image if available
            SizedBox(height: 16),
            TextFormField(
              controller: requirementController,
              decoration: InputDecoration(labelText: 'Requirement'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: nicController,
              decoration: InputDecoration(labelText: 'NIC Number'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: schoolClubNameController,
              decoration: InputDecoration(labelText: 'School or Club Name'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: reqCityController,
              decoration: InputDecoration(labelText: 'City'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                hintText: 'Enter your address here',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: reqContactNumberController,
              decoration: InputDecoration(labelText: 'Contact number'),
            ),
            SizedBox(height: 16),
            Text(
              'Available Items: ${widget.itemCount}',
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Request Items: $requestedItemCount',
              style: TextStyle(
                color: Colors.white70, // Choose your desired color here
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: requestedItemCount > 0
                      ? () {
                    setState(() {
                      requestedItemCount--;
                    });
                  }
                      : null,
                  icon: Icon(Icons.remove),
                ),
                Text(
                  requestedItemCount.toString(),
                  style: TextStyle(fontSize: 20),
                ),
                IconButton(
                  onPressed: requestedItemCount < widget.itemCount
                      ? () {
                    setState(() {
                      requestedItemCount++;
                    });
                  }
                      : null,
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitRequest,
              child: Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}
