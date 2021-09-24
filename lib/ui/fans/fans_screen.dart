import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/blocked/blocked_service.dart';
import 'package:kick_chat/services/follow/follow_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/search/search_service.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/chat/widgets/conversation_skeleton.dart';
import 'package:kick_chat/ui/profile/ui/profile_screen.dart';
import 'package:kick_chat/ui/widgets/circle_button.dart';
import 'package:kick_chat/ui/widgets/profile_avatar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class FanScreen extends StatefulWidget {
  const FanScreen({Key? key}) : super(key: key);

  @override
  _FanScreenState createState() => _FanScreenState();
}

class _FanScreenState extends State<FanScreen> {
  TextEditingController _searchController = TextEditingController();
  TextEditingController _searchFilterController = TextEditingController();
  SearchService _searchService = SearchService();
  UserService _userService = UserService();
  FollowService _followService = FollowService();
  BlockedUserService _blockedUserService = BlockedUserService();
  List<User> users = [];
  StreamController<bool> _userExistStream = StreamController<bool>();
  late Stream<List<User>> _usersStream;
  ScrollController _scrollController = ScrollController();
  bool loading = false;
  StreamController<List<User>> _usersController = StreamController<List<User>>();
  List<User> fetchedUsers = [];
  bool isClicked = false;
  User clickedUser = User();
  bool isFilterButton = false;

  @override
  void initState() {
    loading = true;
    getAllUsers();
    _usersStream = _usersController.stream;
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        loading = false;
      });

      _scrollController.addListener(() {
        if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !loading) {
          getAllUsers();
          _usersStream = _usersController.stream;
        }
      });

      updateUserStream();
    });

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFilterController.dispose();
    _userExistStream.close();
    _usersController.close();
    _scrollController.dispose();
    _userService.disposeUsersStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1.0,
          title: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: !isFilterButton ? searchByUsername() : filterByClubName(),
          ),
          actions: [
            CircleButton(
              icon: !isFilterButton ? MdiIcons.filter : MdiIcons.filterOff,
              iconSize: 30.0,
              onPressed: () {
                setState(() {
                  isFilterButton = !isFilterButton;
                });
              },
            )
          ]),
      body: StreamBuilder<List<User>>(
        stream: _usersStream,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              padding: EdgeInsets.only(left: 10),
              child: ConversationSkeleton(),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: showEmptyState('No user found.', ''),
            );
          } else {
            return Container(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: ScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  if (snapshot.data![index].username == MyAppState.currentUser!.username) {
                    return SizedBox.shrink();
                  }
                  return Container(
                    margin: EdgeInsets.only(left: 10, right: 20),
                    child: searchResults(snapshot.data![index]),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget searchResults(User user) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(left: 10),
          onTap: user.username != MyAppState.currentUser!.username
              ? () async {
                  User? authUser = await _userService.getCurrentUser(user.userID);
                  push(context, ProfileScreen(user: authUser as User));
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
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
              style: TextStyle(
                fontSize: 15,
                color: ColorPalette.grey,
              ),
            ),
          ),
          trailing: FutureBuilder<bool>(
              future: isUserFollowed(user.userID),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return GestureDetector(
                    onTap: () async {
                      try {
                        setState(() {
                          isClicked = true;
                          clickedUser = user;
                        });

                        await _followService.unFollowUser(
                          MyAppState.currentUser!.userID,
                          user.userID,
                        );
                        _usersController.sink.add(fetchedUsers);
                        _usersStream = _usersController.stream;
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
                } else {
                  return GestureDetector(
                    onTap: () {
                      followUser(user);
                    },
                    child: Icon(
                      MdiIcons.accountPlusOutline,
                      color: ColorPalette.grey,
                      size: 30,
                    ),
                  );
                }
              }),
        ),
        Divider(),
      ],
    );
  }

  Widget searchByUsername() {
    return Center(
      child: TextField(
        controller: _searchController,
        onChanged: (input) async {
          if (input.isNotEmpty) {
            List<User> allUsers = await _searchService.searchUsers(input);
            _usersController.sink.add(allUsers);
            _usersStream = _usersController.stream;
          } else {
            _usersController.sink.add(fetchedUsers);
            _usersStream = _usersController.stream;
          }
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchController.text = '';
              _usersController.sink.add(fetchedUsers);
              _usersStream = _usersController.stream;
            },
          ),
          hintText: 'Search by username',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget filterByClubName() {
    return Center(
      child: TextField(
        controller: _searchFilterController,
        onChanged: (input) async {
          if (input.isNotEmpty) {
            List<User> allUsers = await _searchService.filterByClubName(input);
            _usersController.sink.add(allUsers);
            _usersStream = _usersController.stream;
          } else {
            _usersController.sink.add(fetchedUsers);
            _usersStream = _usersController.stream;
          }
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _searchFilterController.text = '';
              _usersController.sink.add(fetchedUsers);
              _usersStream = _usersController.stream;
            },
          ),
          hintText: 'Filter by club name',
          border: InputBorder.none,
        ),
      ),
    );
  }

  getAllUsers() async {
    List<User> allUsers = await _userService.getUsers(10);
    fetchedUsers.addAll(allUsers);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        loading = true;
      });
      if (fetchedUsers.isNotEmpty) {
        _usersController.sink.add(fetchedUsers);
      }

      setState(() {
        loading = false;
      });
    });
  }

  void updateUserStream() {
    if (clickedUser.username.isNotEmpty) {
      _userService.getCurrentUserStream(clickedUser.userID).listen((event) {
        if (isClicked) {
          _usersController.sink.add(fetchedUsers);
          _usersStream = _usersController.stream;
          setState(() {
            isClicked = false;
            clickedUser = User();
          });
        }
      });
    }
  }

  Future<bool> isUserFollowed(String followedUserId) async {
    bool isFollowingUser = await _followService.isFollowingUser(
      MyAppState.currentUser!.userID,
      followedUserId,
    );
    return isFollowingUser;
  }

  Stream<bool> checkIfUserIsFollowed(String followedUserId) async* {
    bool isFollowingThisUser = await _followService.isFollowingUser(MyAppState.currentUser!.userID, followedUserId);
    if (!_userExistStream.isClosed) {
      _userExistStream.sink.add(isFollowingThisUser);
    }
    yield* _userExistStream.stream;
  }

  followUser(User user) async {
    bool isUserBlocked = await _blockedUserService.validateIfUserBlocked(user.userID);
    if (!isUserBlocked) {
      setState(() {
        isClicked = true;
        clickedUser = user;
      });
      try {
        await _followService.followUser(MyAppState.currentUser!, user);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error following user. Try again later.',
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This user is blocked.')),
      );
    }
  }
}
