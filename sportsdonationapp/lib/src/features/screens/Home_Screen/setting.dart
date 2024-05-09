import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sportsdonationapp/src/constants/colors.dart';

import '../Login_Register/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery); // Corrected method call

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        // You can upload the image to Firebase Storage here and update the user's profile with the image URL
        // Example: uploadImageToStorage(_image);
        uploadImageToFirestore(_image!);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> uploadImageToFirestore(File imageFile) async {
    try {
      // Upload image to Firebase Storage
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${FirebaseAuth.instance.currentUser!.uid}.jpg');

      UploadTask uploadTask = ref.putFile(imageFile);

      // Get download URL of uploaded image
      String downloadURL = '';

      await uploadTask.then((taskSnapshot) async {
        downloadURL = await taskSnapshot.ref.getDownloadURL();
      });

      // Update user document in Firestore with profile photo URL
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'profilePhotoURL': downloadURL});
    } catch (error) {
      print('Error uploading image: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.sPSecondaryColor,
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            'Settings',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Text('No user data found');
          }

          var userData = snapshot.data!.data()! as Map<String, dynamic>;
          String userName = userData['name'] ?? 'N/A';
          String userEmail = userData['email'] ?? 'N/A';

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: MyColors.foColor,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _image != null
                                ? FileImage(_image!)
                                : userData['profilePhotoURL'] != null
                                ? NetworkImage(userData['profilePhotoURL'])
                                : AssetImage('assets/Icons/user.png') as ImageProvider<Object>,
                            radius: 60,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: getImage,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: MyColors.sThColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    userName,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    userEmail,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 320),
                  Container(
                    alignment: Alignment.bottomCenter, // Change this alignment as per your requirement
                    child: ElevatedButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary: MyColors.sThColor,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      ),
                      child: Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.white), // Apply white color to the text
                      ),
                    ),
                  )

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
