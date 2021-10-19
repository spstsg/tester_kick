import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/services/follow/follow_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/search/search_service.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/profile/ui/profile_screen.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class UserSearch extends StatefulWidget {
  const UserSearch({Key? key}) : super(key: key);

  @override
  _UserSearchState createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  SearchService _searchService = SearchService();
  FollowService _followService = FollowService();
  UserService _userService = UserService();
  TextEditingController _searchController = TextEditingController();
  List<User> users = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> checkIfUserIsFollowed(String followedUserId) async {
    bool isFollowingThisUser = await _followService.isFollowingUser(
      MyAppState.currentUser!.userID,
      followedUserId,
    );
    return isFollowingThisUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: false,
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Center(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.next,
              onChanged: (input) async {
                if (input.isNotEmpty) {
                  var userList = await _searchService.searchUsers(input);
                  setState(() {
                    users = userList;
                  });
                } else {
                  setState(() {
                    users = [];
                  });
                }
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.text = '';
                    setState(() {
                      users = [];
                    });
                  },
                ),
                hintText: 'Search...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        child: Visibility(
          visible: users.isNotEmpty,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: users.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(left: 10, right: 20),
                child: searchResults(users[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget searchResults(User user) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(top: 10, left: 10),
          onTap: user.username != MyAppState.currentUser!.username
              ? () async {
                  User? authUser = await _userService.getCurrentUser(user.userID);
                  MyAppState.reduxStore!.dispatch(CreateUserAction(authUser!));
                  push(context, ProfileScreen(user: authUser));
                }
              : null,
          leading: ProfileAvatar(
            imageUrl: user.profilePictureURL,
            username: user.username,
            avatarColor: user.avatarColor,
            radius: 25,
            fontSize: 20,
          ),
          title: Row(
            children: [
              Text(
                user.username,
                style: TextStyle(
                  fontSize: 16,
                  color: user.username == MyAppState.currentUser!.username ? ColorPalette.grey : ColorPalette.black,
                ),
              ),
              SizedBox(width: 10),
              Visibility(
                visible: user.username == MyAppState.currentUser!.username,
                child: Text(
                  '(You)',
                  style: TextStyle(
                    color: ColorPalette.grey,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              user.team,
              style: TextStyle(fontSize: 15, color: ColorPalette.grey),
            ),
          ),
          trailing: FutureBuilder<bool>(
            future: checkIfUserIsFollowed(user.userID),
            initialData: false,
            builder: (context, snapshot) {
              if (snapshot.data == false) {
                return Visibility(
                  visible: user.username != MyAppState.currentUser!.username,
                  child: Icon(
                    Icons.arrow_forward,
                    color: ColorPalette.primary,
                    size: 30,
                  ),
                );
              } else {
                return GestureDetector(
                  onTap: () async {
                    try {
                      _followService.unFollowUser(MyAppState.currentUser!.userID, user.userID);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Cannot unfollow user. Try again later.',
                          ),
                        ),
                      );
                    }
                  },
                  child: Icon(
                    MdiIcons.accountCheckOutline,
                    color: ColorPalette.primary,
                    size: 30,
                  ),
                );
              }
            },
          ),
        ),
        Divider(),
      ],
    );
  }
}
