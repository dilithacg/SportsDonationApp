import 'package:flutter/material.dart';
import 'package:sportsdonationapp/src/constants/colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideo {
  final String title;
  final String videoId;
  final String thumbnailUrl; // Added thumbnail URL

  YoutubeVideo({
    required this.title,
    required this.videoId,
    required this.thumbnailUrl, // Initialize thumbnail URL
  });
}

// Sample list of videos with added thumbnails
List<YoutubeVideo> youtubeVideos = [
  YoutubeVideo(title: "5 CRICKET BATTING TIPS that will help YOU IMPROVE TODAY!!!", videoId: "KY8gsVeKn0w", thumbnailUrl: "https://i.ytimg.com/vi/KY8gsVeKn0w/hqdefault.jpg?sqp=-oaymwEbCKgBEF5IVfKriqkDDggBFQAAiEIYAXABwAEG\u0026rs=AOn4CLC-lcEg-CzPvt5ZFWQazk_lJbW25w"),
  YoutubeVideo(title: "How to play SPIN BOWLING - Full Batting Guide", videoId: "Nx7gcnTT_Nw", thumbnailUrl: "https://i.ytimg.com/vi/Nx7gcnTT_Nw/hqdefault.jpg?sqp=-oaymwEbCKgBEF5IVfKriqkDDggBFQAAiEIYAXABwAEG\u0026rs=AOn4CLDHjwUTWNopK-e6cTW4ybVDBGDFDA"),
  YoutubeVideo(title: "How to put reverse swing", videoId: "8ZAx-gsyZck", thumbnailUrl: "https://i.ytimg.com/vi/8ZAx-gsyZck/hqdefault.jpg?sqp=-oaymwE1CKgBEF5IVfKriqkDKAgBFQAAiEIYAXABwAEG8AEB-AH-BIAC4AKKAgwIABABGFIgZSgzMA8=\u0026rs=AOn4CLBPYbg8_UcdLGwtz"),
  YoutubeVideo(title: "Footwork | Top Tips | Cricket How-To | Steve Smith Cricket Academy", videoId: "HEHggOOds1w", thumbnailUrl: "https://yt3.ggpht.com/ytc/AIdro_lyGDq8-aFOV4UKHI8GdhwV82RQgOVUIJL7R5rNWeUBJA=s48-c-k-c0x00ffffff-no-rj"),
  YoutubeVideo(title: "5 MOST BASIC FOOTBALL SKILLS TO LEARN", videoId: "pH_G1f6KzfI", thumbnailUrl: "https://i.ytimg.com/vi/pH_G1f6KzfI/hqdefault.jpg?sqp=-oaymwEbCKgBEF5IVfKriqkDDggBFQAAiEIYAXABwAEG\u0026rs=AOn4CLC4_Q6I_ThT-mcRhX_jfkHiRJ35wA"),
  YoutubeVideo(title: "The 10 Best 1v1 Skills in Soccer", videoId: "U8WCRz0Yh4Q", thumbnailUrl: "https://i.ytimg.com/vi/nrOfIhsw-Hs/hqdefault.jpg?sqp=-oaymwEbCKgBEF5IVfKriqkDDggBFQAAiEIYAXABwAEG\u0026rs=AOn4CLDuwp0DGJRMi_ndnTniKpNSZADsnw"),
  YoutubeVideo(title: "Best Rugby Skills - Offloads, Steps, Skills", videoId: "AbjjDxqEKS4", thumbnailUrl: "https://encrypted-tbn0.gstatic.com/shopping?q=tbn:ANd9GcR4DIsosPouZCnnwalDybIVEYdNqUOKofa2y5jQOjHRFAWuCyyNEtLTykg-YW7k3DvKTxiLzRw8"),
  YoutubeVideo(title: "How to Pass a Rugby Ball ", videoId: "4WaBgY1POKw", thumbnailUrl: "https://i.ytimg.com/vi/4WaBgY1POKw/hqdefault.jpg?sqp=-oaymwEbCKgBEF5IVfKriqkDDggBFQAAiEIYAXABwAEG\u0026rs=AOn4CLBvHPYv3YsUHq-_6mQTwFTrF8muxA"),
  YoutubeVideo(title: "3 Step Approach Jump Technique | How To Jump Higher", videoId: "B7vbjJ2wQQQ", thumbnailUrl: "https://i.ytimg.com/vi/B7vbjJ2wQQQ/hqdefault.jpg?sqp=-oaymwEbCKgBEF5IVfKriqkDDggBFQAAiEIYAXABwAEG\u0026rs=AOn4CLAUntoPphN7x1mlv236f3mP5gkVbQ"),
  YoutubeVideo(title: "How to Serve a Volleyball (Best Tutorial For Begginers)", videoId: "9Xd-nuj54As", thumbnailUrl: "https://yt3.ggpht.com/qPks4hBSUgrL6qoIJVGSXw8GNzL_oVsIdnQpzvVd4VPauUG6qVgYbjGhnFRl1XL7uhmdurQ8eA=s48-c-k-c0x00ffffff-no-rj"),
  YoutubeVideo(title: "Useful hard carrom trick shots, carrom board tricks, best carrom shots, carrom board game", videoId: "6W9lqySbcgQ", thumbnailUrl: "https://i.ytimg.com/vi/z8vvJpNceeg/hqdefault.jpg?sqp=-oaymwEbCKgBEF5IVfKriqkDDggBFQAAiEIYAXABwAEG\u0026rs=AOn4CLBagQMEwGfcn6z6YwNjtkI8bIXI9w"),





  // Add more videos with their thumbnails
];

class YoutubeVideoListScreen extends StatelessWidget {
  final List<YoutubeVideo> videos;

  YoutubeVideoListScreen({Key? key, required this.videos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.sPSecondaryColor,
        automaticallyImplyLeading: false,
        title: const Center(
          child: Text(
            'Playlist',
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
            ),
          ),
        ), // Consider using ThemeData for app-wide consistency
      ),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 5, // Added elevation for better visual hierarchy
            margin: EdgeInsets.all(8), // Added margin for spacing
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => YoutubePlayerScreen(videoId: videos[index].videoId),
                  ),
                );
              },
              leading: Image.network(videos[index].thumbnailUrl, width: 100,), // Display thumbnail
              title: Text(
                videos[index].title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Icon(Icons.play_circle_fill, color: Colors.red,), // Play icon
            ),
          );
        },
      ),
    );
  }
}

class YoutubePlayerScreen extends StatefulWidget {
  final String videoId;

  YoutubePlayerScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  _YoutubePlayerScreenState createState() => _YoutubePlayerScreenState();
}

class _YoutubePlayerScreenState extends State<YoutubePlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Video'),
        backgroundColor: Colors.deepPurple, // Consistent color scheme
      ),
      body: Column( // Use Column to arrange title and player vertically
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0), // Add padding around the title for better layout

          ),
          SizedBox(height: 0), // Space between title and video player
          Expanded( // Make YoutubePlayer take the remaining space
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.deepPurple, // Custom progress bar color
            ),
          ),
        ],
      ),
    );
  }
}