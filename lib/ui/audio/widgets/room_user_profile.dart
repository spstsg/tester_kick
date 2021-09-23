import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';

// class UserProfileImage extends StatelessWidget {
//   final String imageUrl;
//   final double size;

//   const UserProfileImage({
//     Key? key,
//     required this.imageUrl,
//     this.size = 48.0,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(size / 2 - size / 18),
//       child: Image.network(
//         imageUrl,
//         height: size,
//         width: size,
//         fit: BoxFit.cover,
//       ),
//     );
//   }
// }

class RoomUserProfile extends StatelessWidget {
  final String creatorName;
  final String imageUrl;
  final String name;
  final String avatarColor;
  final double size;
  final bool hasQueueNumber;
  final int queueNumber;
  final bool isMuted;
  final VoidCallback onPressed;

  const RoomUserProfile({
    required this.creatorName,
    required this.imageUrl,
    required this.name,
    required this.avatarColor,
    this.size = 48.0,
    this.hasQueueNumber = false,
    this.queueNumber = 0,
    this.isMuted = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Column(
              children: [
                hasQueueNumber && queueNumber > 0
                    ? Container(
                        child: Text(
                          '$queueNumber',
                          style: TextStyle(
                            color: ColorPalette.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : Container(
                        child: Text(
                          '',
                          style: TextStyle(
                            color: ColorPalette.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                Container(
                  padding: EdgeInsets.all(6.0),
                  child: ProfileAvatar(
                    imageUrl: imageUrl,
                    username: name,
                    avatarColor: avatarColor,
                    radius: size / 2 - size / 18,
                    fontSize: 30,
                  ),
                ),
              ],
            ),
            if (creatorName == MyAppState.currentUser!.username &&
                name != MyAppState.currentUser!.username)
              Positioned(
                left: 0,
                top: 25,
                child: GestureDetector(
                  onTap: onPressed,
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: const BoxDecoration(
                      color: ColorPalette.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      CupertinoIcons.clear,
                      size: 14.0,
                    ),
                  ),
                ),
              ),
            if (hasQueueNumber && queueNumber > 0)
              Positioned(
                right: 0,
                top: 25,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: const BoxDecoration(
                    color: ColorPalette.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    CupertinoIcons.hand_raised,
                    size: 14.0,
                    color: Colors.red,
                  ),
                ),
              ),
            // if (isMuted)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: !isMuted ? Colors.red : Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  !isMuted ? CupertinoIcons.mic_slash_fill : CupertinoIcons.mic_fill,
                  size: 14,
                  color: !isMuted ? Colors.white : Colors.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        Flexible(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ColorPalette.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
