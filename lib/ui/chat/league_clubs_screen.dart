import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/models/club_model.dart';
import 'package:kick_chat/services/clubs/clubs_service.dart';
import 'package:kick_chat/services/helper.dart';
// import 'package:kick_chat/ui/chat/conversation_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LeagueClubsScreen extends StatefulWidget {
  final String leagueName;
  final String leagueAsset;
  final String country;

  LeagueClubsScreen({
    Key? key,
    required this.leagueName,
    required this.leagueAsset,
    required this.country,
  }) : super(key: key);

  @override
  _LeagueClubsScreenState createState() => _LeagueClubsScreenState();
}

class _LeagueClubsScreenState extends State<LeagueClubsScreen> {
  ClubService clubService = ClubService();
  late Future<List<Club>> allClubsFuture;

  @override
  void initState() {
    super.initState();
    allClubsFuture = clubService.getClubs(widget.country, widget.leagueName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 90,
        leading: Container(
          child: Row(
            children: [
              IconButton(
                icon: Icon(MdiIcons.chevronLeft, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
              CircleAvatar(
                backgroundColor: ColorPalette.primary,
                child: ClipOval(
                  child: Image(
                    height: 40,
                    width: 40,
                    image: AssetImage(widget.leagueAsset),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          widget.leagueName,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                width: double.infinity,
                child: _buildClubs(),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildClubs() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: FutureBuilder<List<Club>>(
        future: allClubsFuture,
        initialData: [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
            return Container(
              height: MediaQuery.of(context).size.height / 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: showEmptyState(
                    'There is an issue',
                    'Please check again.',
                  ),
                ),
              ),
            );
          } else {
            return ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Club club = snapshot.data![index];
                return Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => ConversationsScreen(),
                        //   ),
                        // );
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 20),
                        leading: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 20.0,
                              backgroundColor: ColorPalette.primary,
                              child: CircleAvatar(
                                radius: 20.0,
                                backgroundImage: CachedNetworkImageProvider(
                                  'https://res.cloudinary.com/ratingapp/image/upload/v1629150253/clubs/${club.image}',
                                ),
                              ),
                            )),
                        title: Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            club.clubName,
                            style: TextStyle(
                              fontSize: 18,
                              color: ColorPalette.primary,
                            ),
                          ),
                        ),
                        subtitle: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.end,
                                spacing: 10,
                                children: [
                                  Icon(Icons.add, size: 22),
                                  Text(
                                    'Add',
                                    style: TextStyle(
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20, right: 15),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.end,
                                spacing: 10,
                                children: [
                                  Icon(Icons.people, size: 22),
                                  Text(
                                    '${club.fanCount}',
                                    style: TextStyle(
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Divider(), //                           <-- Divider
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
