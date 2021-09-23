import 'package:flutter/material.dart';
import 'package:kick_chat/models/image_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/files/file_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/profile/widgets/profile_images_skeleton.dart';
import 'package:kick_chat/ui/widgets/full_screen_image_viewer.dart';
import 'package:transparent_image/transparent_image.dart';

class ProfileImages extends StatefulWidget {
  final User user;
  const ProfileImages({required this.user});

  @override
  _ProfileImagesState createState() => _ProfileImagesState();
}

class _ProfileImagesState extends State<ProfileImages> {
  late Stream<ImageModel> userImages;
  FileService _fileService = FileService();

  @override
  void initState() {
    userImages = _fileService.getUserImages(widget.user.userID);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _fileService.disposeUserImagesStream();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<ImageModel>(
        stream: userImages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ProfileImagesSkeleton();
          } else if (!snapshot.hasData || snapshot.hasData && snapshot.data!.images.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 150),
              child: Center(
                child: showEmptyState(
                  'No Images yet.',
                  'All images will show up here',
                ),
              ),
            );
          } else {
            return GridView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.images.length,
              physics: ScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                return Container(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          push(
                            context,
                            FullScreenImageViewer(
                              imageUrl: '',
                              imageStringFiles: [snapshot.data!.images.reversed.toList()[index]],
                              imageFiles: [],
                            ),
                          );
                        },
                        child: FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: snapshot.data!.images.reversed.toList()[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
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
