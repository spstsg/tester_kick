import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import "package:collection/collection.dart";
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/scores/livescores_service.dart';
import 'package:kick_chat/services/sharedpreferences/shared_preferences_service.dart';
import 'package:kick_chat/ui/livescores/ui/screens/game_event_details.dart';
import 'package:kick_chat/ui/livescores/ui/widgets/widget_matches_skeleton.dart';
import 'package:kick_chat/ui/livescores/ui/widgets/widgets_events.dart';

class AllGamesScreen extends StatefulWidget {
  const AllGamesScreen({Key? key}) : super(key: key);

  @override
  AllGamesScreenState createState() => AllGamesScreenState();
}

class AllGamesScreenState extends State<AllGamesScreen> {
  LiveScores _liveScores = LiveScores();
  SharedPreferencesService _sharedPreferences = SharedPreferencesService();
  int _selectedPost = 1;
  late Map groupedData;
  List groupKeys = [];
  late Stream<dynamic> todaysMatchFuture;
  String selectedValue = 'Filter by country';

  @override
  void initState() {
    todaysMatchFuture = _liveScores.getTodaysMatches();
    super.initState();
  }

  @override
  void dispose() {
    _liveScores.disposeTodaysMatchesStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: countrySelectDropdown(),
          ),
          SizedBox(height: 10),
          Expanded(child: _todaysMatch()),
        ],
      ),
    );
  }

  StreamBuilder<dynamic> _todaysMatch() {
    return StreamBuilder<dynamic>(
      stream: todaysMatchFuture,
      initialData: [],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: MediaQuery.of(context).size.height,
            child: MatchesSkeleton(),
          );
        } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true) || snapshot.data['response'].isEmpty) {
          return Center(
            child: Center(
              child: showEmptyState(
                '',
                'No games yet.',
              ),
            ),
          );
        } else {
          if (selectedValue == 'All games' || selectedValue == 'Filter by country') {
            groupedData = groupBy(snapshot.data['response'], (dynamic obj) => obj['league']['id']);
            groupKeys = groupedData.keys.toList();
          } else {
            getCountryFilter().then((getCountryName) {
              var filtered =
                  snapshot.data!['response'].where((i) => i['league']!['country'] == getCountryName).toList();
              groupedData = groupBy(
                filtered,
                (dynamic obj) => obj['league']['id'],
              );
              groupKeys = groupedData.keys.toList();
            });
            if (groupKeys.isEmpty) {
              return Center(
                child: Center(
                  child: showEmptyState(
                    '',
                    'No games yet.',
                  ),
                ),
              );
            }
          }

          return ListView.builder(
            physics: ScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: groupKeys.length,
            itemBuilder: (BuildContext context, int index) {
              var group = groupKeys[index];
              return Column(
                children: [
                  Container(
                    color: Colors.blue,
                    padding: EdgeInsets.only(left: 25, top: 10, bottom: 10),
                    height: 50,
                    child: CardHeader(
                      name:
                          '${groupedData[group][0]['league']['country']} - ${truncateString(groupedData[group][0]['league']['name'], 25)}',
                      logo: groupedData[group][0]['league']['logo'] != null
                          ? groupedData[group][0]['league']['logo']
                          : groupedData[group][0]['league']['flag'],
                    ),
                  ),
                  Container(
                    color: ColorPalette.greyWhite,
                    padding: EdgeInsets.only(left: 30, top: 8, bottom: 10),
                    height: 40,
                    child: Row(
                      children: [
                        Text(
                          groupedData[group][0]['league']['round'],
                          style: TextStyle(
                            color: ColorPalette.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (var key in groupedData[group])
                    CardEventItemNew(
                      isSelected: index == _selectedPost,
                      dateMatch: key['fixture']['date'],
                      timeMatch: key['fixture']['status']['elapsed'],
                      shortStatus: key['fixture']['status']['short'],
                      timestamp: key['fixture']['timestamp'],
                      nameHome: key['teams']['home']['name'],
                      nameAway: key['teams']['away']['name'],
                      logoHome: key['teams']['home']['logo'],
                      logoAway: key['teams']['away']['logo'],
                      scoreAway: key['goals']['away'],
                      scoreHome: key['goals']['home'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameEventDetails(
                              fixtureId: key['fixture']['id'].toString(),
                              country: key['league']['country'],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          );
        }
      },
    );
  }

  Future<bool> setCountryFilter(String country) async {
    return _sharedPreferences.setSharedPreferencesString('Country', country);
  }

  getCountryFilter() async {
    String savedCountry = await _sharedPreferences.getSharedPreferencesString('Country');
    setState(() {});
    return savedCountry;
  }

  Widget countrySelectDropdown() {
    List<String> _listItems = [
      'All games',
      'England',
      'France',
      'Germany',
      'Italy',
      'Spain',
    ];
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      margin: EdgeInsets.only(left: 10.0, top: 5, right: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: ColorPalette.white,
        border: Border.all(color: ColorPalette.primary),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          hint: Text(
            selectedValue,
            style: TextStyle(
              color: ColorPalette.primary,
              fontSize: 18,
            ),
          ),
          items: _listItems.map<DropdownMenuItem<String>>((String country) {
            return DropdownMenuItem<String>(
              value: country,
              child: Text(
                country,
                style: TextStyle(
                  color: ColorPalette.primary,
                  fontSize: 18,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) async {
            String getCountryName = await _sharedPreferences.getSharedPreferencesString('Country');
            if (getCountryName.isEmpty || getCountryName == '') {
              showCupertinoAlert(
                context,
                'Alert',
                'Would you like to save your selection?',
                'Save',
                'Do not save',
                '',
                true,
              );
              setState(() {
                selectedValue = newValue == 'All games' ? 'Filter by country' : newValue!;
                setCountryFilter(selectedValue);
              });
            } else {
              setState(() {
                selectedValue = newValue == 'All games' ? 'Filter by country' : newValue!;
                setCountryFilter(selectedValue);
              });
            }
          },
        ),
      ),
    );
  }
}
