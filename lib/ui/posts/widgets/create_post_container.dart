import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/app_state.dart';
import 'package:kick_chat/ui/posts/create_post_screen.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CreatePostContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, User>(
      distinct: true,
      converter: (store) => store.state.user,
      builder: (context, storeUser) => Container(
        height: 150,
        child: Card(
          elevation: 0.0,
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      new MaterialPageRoute<Null>(
                        builder: (BuildContext context) {
                          return new CreatePostScreen();
                        },
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 15, left: 10),
                    child: Row(
                      children: [
                        ProfileAvatar(
                          imageUrl: storeUser.profilePictureURL.isNotEmpty
                              ? storeUser.profilePictureURL
                              : MyAppState.currentUser!.profilePictureURL,
                          username: MyAppState.currentUser!.username,
                          avatarColor: MyAppState.currentUser!.avatarColor,
                          radius: MyAppState.currentUser!.profilePictureURL != '' ? 20 : 45.0,
                          fontSize: 20,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            'What\'s on your mind?',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const Divider(height: 10.0, thickness: 0.5),
                SizedBox(height: 10),
                Container(
                  height: 40.0,
                  margin: EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            new MaterialPageRoute<Null>(
                              builder: (BuildContext context) {
                                return new CreatePostScreen(openImagePicker: true);
                              },
                              fullscreenDialog: true,
                            ),
                          );
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            color: ColorPalette.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.photo_library,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                        label: Text(
                          'Photo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                            fontSize: 14,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.red[100]),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.red.shade100),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            new MaterialPageRoute<Null>(
                              builder: (BuildContext context) {
                                return new CreatePostScreen(openGif: true);
                              },
                              fullscreenDialog: true,
                            ),
                          );
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            color: ColorPalette.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            MdiIcons.gif,
                            color: Colors.orange,
                            size: 18,
                          ),
                        ),
                        label: Text(
                          'Gif',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                            fontSize: 14,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.orange[100]),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.orange.shade100),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
