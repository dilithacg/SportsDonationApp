import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
//import 'package:liquid_swipe/liquid_swipe.dart';
//import 'package:sportsdonationapp/src/constants/colors.dart';
import 'package:sportsdonationapp/src/constants/images_string.dart';
import 'package:sportsdonationapp/src/features/screens/Login_Register/login_screen.dart';
import '../../../constants/colors.dart';


class OnBoardingScreen extends StatelessWidget {
  OnBoardingScreen({Key? key}) : super(key: key);

  final List<PageViewModel> pages=[
    PageViewModel(
      title: '1 page',
      body: 'description',
      footer: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple, // Change the color to your desired color
        ),
        child: const Text("Let's Go"),
      ),
      image: Center(
        child: Image.asset(ins1),
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    PageViewModel(
      title: '2 page',
      body: 'description',
      footer: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple, // Change the color to your desired color
        ),
        child: const Text("Let's Go"),
      ),
      image: Center(
        child: Image.asset(ins2),
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    PageViewModel(
      title: '3 page',
      body: 'description',
      footer: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple, // Change the color to your desired color
        ),
        child: const Text("Let's Go"),
      ),
      image: Center(
        child: Image.asset(ins3),
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('onboarding'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,

      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: IntroductionScreen(
          pages: pages,
          dotsDecorator: const DotsDecorator(
            size: Size(15,15),
            color: Colors.deepPurple,
            activeSize: Size.square(20),
            activeColor: Colors.deepPurpleAccent,
          ),
          showDoneButton: true,
          done: const Text('Done',style: TextStyle(fontSize: 20),),
          showSkipButton: true,
          skip: const Text('Skip',style: TextStyle(fontSize: 20),),
          showNextButton: true,
          next: const Icon(Icons.arrow_forward,size: 25,),
          onDone: () => onDone(context),
          curve: Curves.bounceOut,
        ),
      ),
    );
  }
  void onDone(context){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  const LoginScreen()));
  }
}

