import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/widgets/circle_avatar.dart';

class ProfileAvatar extends StatelessWidget {
  final dynamic imageUrl;
  final bool isActive;
  final String username;
  final String avatarColor;
  final double radius;
  final double fontSize;
  final bool showPlaceholderImage;
  final showIcon;
  final VoidCallback? onPressed;

  const ProfileAvatar({
    required this.imageUrl,
    this.isActive = false,
    this.username = '',
    this.avatarColor = '#ffffff',
    this.radius = 20.0,
    this.fontSize = 20.0,
    this.showIcon = false,
    this.showPlaceholderImage = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        imageUrl != '' && !showPlaceholderImage
            ? CircleAvatar(
                radius: radius,
                backgroundColor: ColorPalette.primary,
                child: CircleAvatar(
                  radius: radius,
                  backgroundColor: hexStringToColor(avatarColor),
                  backgroundImage: imageUrl is String ? Image.network(imageUrl).image : Image.file(imageUrl).image,
                ),
              )
            : CircleProfileAvatar(
                username: username,
                avatarColor: avatarColor,
                radius: radius,
                fontSize: fontSize,
                showPlaceholderImage: showPlaceholderImage,
              ),
        isActive
            ? Positioned(
                bottom: 0.0,
                right: 0.0,
                child: Container(
                  height: 15.0,
                  width: 15.0,
                  decoration: BoxDecoration(
                    color: ColorPalette.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 2.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : showIcon
                ? Positioned(
                    bottom: 0.0,
                    right: 0.0,
                    child: Container(
                      height: 25.0,
                      width: 25.0,
                      child: RawMaterialButton(
                        onPressed: onPressed,
                        elevation: 2.0,
                        fillColor: ColorPalette.white,
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: ColorPalette.primary,
                          size: 18,
                        ),
                        padding: EdgeInsets.only(top: 2),
                        shape: CircleBorder(),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
      ],
    );
  }
}
