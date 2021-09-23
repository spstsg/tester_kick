import 'package:flutter/material.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileAvatar(
            imageUrl: user.profilePictureURL,
            username: user.username,
            avatarColor: user.avatarColor,
            radius: 45.0,
            fontSize: 20,
          ),
          const SizedBox(width: 6.0),
          Flexible(
            child: Text(
              user.username,
              style: const TextStyle(fontSize: 16.0),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
