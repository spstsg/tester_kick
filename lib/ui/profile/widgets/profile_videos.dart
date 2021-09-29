import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/files/file_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/profile/widgets/profile_images_skeleton.dart';
import 'package:kick_chat/ui/widgets/fullscreen_video_viewer.dart';
import 'package:transparent_image/transparent_image.dart';

class ProfileVideos extends StatefulWidget {
  final User user;
  const ProfileVideos({required this.user});

  @override
  _ProfileVideosState createState() => _ProfileVideosState();
}

class _ProfileVideosState extends State<ProfileVideos> {
  late Stream<List<Map<String, dynamic>>> userVideos;
  FileService _fileService = FileService();

  @override
  void initState() {
    super.initState();
    userVideos = _fileService.getUserVideoFiles(widget.user.userID);
  }

  @override
  void dispose() {
    super.dispose();
    _fileService.disposeUserVideoStream();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: userVideos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ProfileImagesSkeleton();
          } else if (!snapshot.hasData || snapshot.hasData && snapshot.data!.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 150),
              child: Center(
                child: showEmptyState(
                  'No videos yet.',
                  'All videos you added will show up here',
                ),
              ),
            );
          } else {
            return GridView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              physics: ScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                if (snapshot.data![index]['hide'] == true &&
                    snapshot.data![index]['userId'] != MyAppState.currentUser!.userID) {
                  return SizedBox.shrink();
                }
                return Container(
                  child: Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          push(
                            context,
                            FullScreenVideoViewer(
                              heroTag: getRandomString(10),
                              videoUrl: snapshot.data![index]['url'],
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: snapshot.data![index]['videoThumbnail'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            Center(
                              child: Icon(
                                Icons.play_circle_fill_outlined,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
