import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/livescores/ui/widgets/widget_stats.dart';

class MatchStatsScreen extends StatefulWidget {
  final matchDetails;

  MatchStatsScreen({required this.matchDetails});

  @override
  _MatchStatsScreenState createState() => _MatchStatsScreenState();
}

class _MatchStatsScreenState extends State<MatchStatsScreen> {
  calculatePercentage(valueOne, valueTwo) {
    if (valueOne == null) {
      valueOne = 0;
    }
    if (valueTwo == null) {
      valueTwo = 0;
    }
    if (valueOne is String && valueTwo is String) {
      var valueOneList = valueOne.split('%');
      var valueTwoList = valueTwo.split('%');
      if (valueOneList.length == 2 && valueTwoList.length == 2) {
        valueOne = int.parse(valueOneList[0]);
        valueTwo = int.parse(valueTwoList[0]);
      }
    }
    return valueOne / (valueOne + valueTwo);
  }

  List<dynamic> mergeTeamsStatistics(statistics) {
    List<dynamic> team1 = statistics[0]['statistics'];
    List<dynamic> team2 = statistics[1]['statistics'];
    for (var i = 0; i < team1.length; i++) {
      team1[i]['value1'] = team2[i]['value'];
    }
    return team1;
  }

  @override
  Widget build(BuildContext context) {
    var statistics = widget.matchDetails['statistics'];
    if (statistics.isEmpty) {
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.only(top: 100),
            child: Center(
              child: showEmptyState(
                'No stats yet',
                'Match stats will be displayed here',
              ),
            ),
          );
        },
      );
    }
    return ListView.builder(
      physics: ScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: statistics.length > 0 ? 1 : 0,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: Column(
                children: [
                  for (var key in mergeTeamsStatistics(statistics))
                    if (key['value'] != null && key['type'] == 'Ball Possession')
                      CardLinearBig(
                        label: key['type'],
                        value: calculatePercentage(
                          key!['value'],
                          key['value1'],
                        ),
                        home: key!['value'] != null ? key!['value'] : 0,
                        away: key['value1'] != null ? key['value1'] : 0,
                      ),
                  for (var key in mergeTeamsStatistics(statistics))
                    if (key['value'] != null && key['type'] != 'Ball Possession')
                      CardLinearSmall(
                        label: key['type'],
                        value: calculatePercentage(
                          key['value'],
                          key['value1'],
                        ),
                        home: key!['value'] != null ? key!['value'] : 0,
                        away: key['value1'] != null ? key['value1'] : 0,
                      ),
                ],
              ),
            ),
            SizedBox(height: 50.0),
          ],
        );
      },
    );
  }
}
