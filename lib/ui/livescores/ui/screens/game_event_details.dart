import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/scores/livescores_service.dart';
import 'package:kick_chat/ui/livescores/ui/screens/game_chat_screen.dart';
import 'package:kick_chat/ui/livescores/ui/screens/lineups_screen.dart';
import 'package:kick_chat/ui/livescores/ui/screens/match_stats_screen.dart';
import 'package:kick_chat/ui/livescores/ui/widgets/widget_game_details_skeleton.dart';
import 'package:kick_chat/ui/livescores/ui/widgets/widgets_events.dart';

class GameEventDetails extends StatefulWidget {
  final String fixtureId;
  final String country;

  const GameEventDetails({Key? key, required this.fixtureId, required this.country})
      : super(key: key);

  @override
  _GameEventDetailsState createState() => _GameEventDetailsState();
}

class _GameEventDetailsState extends State<GameEventDetails> {
  LiveScores _liveScores = LiveScores();
  ScrollController _controller = ScrollController();
  PageController _pageController = PageController();
  List<String> countries = ['England', 'Spain', 'Germany', 'France', 'Italy', 'Indonesia'];
  bool countryIsFound = false;

  int? _indexTabEvent;
  late Stream<dynamic> matchDetailsStream;
  late Map matchDetails = {};

  _animateToPage(int page) {
    _pageController.jumpToPage(page);
  }

  @override
  void initState() {
    _indexTabEvent = 0;
    matchDetailsStream = _liveScores.getMatchDetails(widget.fixtureId);
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (countries.contains(widget.country)) {
        _indexTabEvent = 0;
        setState(() {
          countryIsFound = true;
        });
      } else {
        _indexTabEvent = 1;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _liveScores.disposeMatchDetailsStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mSize = MediaQuery.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: StreamBuilder<dynamic>(
        stream: matchDetailsStream,
        initialData: null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return GameDetailsSkeleton();
          } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Center(
                child: showEmptyState(
                  '',
                  'No match details',
                ),
              ),
            );
          } else {
            var fixtureDetails = snapshot.data!['response'][0];
            matchDetails = fixtureDetails;
            return NestedScrollView(
              controller: _controller,
              headerSliverBuilder: (context, isScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 250,
                    title: CardBarEvent(
                      name: truncateString(fixtureDetails['league']['name'], 25),
                      logo: fixtureDetails['league']['logo'] != null
                          ? fixtureDetails['league']['logo']
                          : fixtureDetails['league']['flag'],
                    ),
                    pinned: true,
                    backgroundColor: theme.primaryColorDark,
                    automaticallyImplyLeading: false,
                    flexibleSpace: BarEventDetails(
                      dateMatch: fixtureDetails['fixture']['date'],
                      timeMatch: fixtureDetails['fixture']['status']['elapsed'].toString(),
                      shortStatus: fixtureDetails['fixture']['status']['short'],
                      timestamp: fixtureDetails['fixture']['timestamp'],
                      nameHome: fixtureDetails['teams']['home']['name'],
                      nameAway: fixtureDetails['teams']['away']['name'],
                      logoHome: fixtureDetails['teams']['home']['logo'],
                      logoAway: fixtureDetails['teams']['away']['logo'],
                      scoreAway: fixtureDetails['goals']['away'],
                      scoreHome: fixtureDetails['goals']['home'],
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size(mSize.size.width, 40.0),
                      child: CardTabsEvents(
                        children: [
                          countryIsFound
                              ? TabTileEvent(
                                  isSelected: _indexTabEvent == 0,
                                  label: 'Chats',
                                  icon: FontAwesomeIcons.solidComments,
                                  onTap: () {
                                    setState(() {
                                      _indexTabEvent = 0;
                                      _animateToPage(_indexTabEvent!);
                                    });
                                  },
                                )
                              : SizedBox.shrink(),
                          TabTileEvent(
                            isSelected: _indexTabEvent == 1,
                            label: 'Stats',
                            icon: FontAwesomeIcons.chartPie,
                            onTap: () {
                              setState(() {
                                _indexTabEvent = 1;
                                matchDetails = fixtureDetails;
                                _animateToPage(_indexTabEvent!);
                              });
                            },
                          ),
                          TabTileEvent(
                            isSelected: _indexTabEvent == 2,
                            label: 'Line Ups',
                            icon: FontAwesomeIcons.users,
                            onTap: () {
                              setState(() {
                                _indexTabEvent = 2;
                                matchDetails = fixtureDetails;
                                _animateToPage(_indexTabEvent!);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: PageView(
                onPageChanged: (val) {
                  setState(() {
                    _indexTabEvent = val;
                  });
                },
                controller: _pageController,
                children: [
                  countryIsFound
                      ? GameChatScreen(matchDetails: matchDetails, user: MyAppState.currentUser!)
                      : MatchStatsScreen(matchDetails: matchDetails),
                  MatchStatsScreen(matchDetails: matchDetails),
                  LineUpScreen(matchDetails: matchDetails),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class CardTabsEvents extends StatelessWidget {
  final children;

  CardTabsEvents({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.primaryColorDark.withOpacity(0.0),
            theme.primaryColorDark,
            theme.primaryColorDark,
          ],
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ),
    );
  }
}
