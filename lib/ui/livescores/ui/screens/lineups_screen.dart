import 'package:flutter/material.dart';
import 'package:kick_chat/ui/livescores/ui/widgets/widgets_lineup.dart';

class LineUpScreen extends StatefulWidget {
  final matchDetails;

  LineUpScreen({required this.matchDetails});

  @override
  _LineUpScreenState createState() => _LineUpScreenState();
}

class _LineUpScreenState extends State<LineUpScreen> {
  int _selectedClub = 1;

  @override
  Widget build(BuildContext context) {
    final mSize = MediaQuery.of(context).size;

    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            width: mSize.width,
            child: Column(
              children: [
                RowTabLineup(
                  selectedClub: _selectedClub,
                  homeName: widget.matchDetails['teams']['home']['name'],
                  awayName: widget.matchDetails['teams']['away']['name'],
                  onClubA: () {
                    setState(() {
                      _selectedClub = 1;
                    });
                  },
                  onClubB: () {
                    setState(() {
                      _selectedClub = 2;
                    });
                  },
                ),
                widget.matchDetails['lineups'].length > 0 &&
                        widget.matchDetails['lineups'][_selectedClub - 1]['formation'] != null
                    ? Center(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            widget.matchDetails['lineups'][_selectedClub - 1]['formation'],
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
                SizedBox(height: 10),
                widget.matchDetails['lineups'].length > 0
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: ListView.builder(
                          physics: ScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: widget.matchDetails['lineups'].length > 0 ? 1 : 0,
                          itemBuilder: (BuildContext context, int index) {
                            int selectedClub = _selectedClub == 1 ? 0 : 1;

                            return Column(
                              children: [
                                for (var key in widget.matchDetails['lineups'][selectedClub]
                                    ['startXI'])
                                  TeamList(
                                    logo: '',
                                    name: key['player']['name'],
                                    number: key['player']['number'],
                                  ),
                              ],
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Container(
                          child: Text('No data available'),
                        ),
                      ),
                SizedBox(height: 5),
              ],
            ),
          ),
        ),
        Container(
          color: Colors.blue,
          padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
          child: Text(
            'Substitions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10),
        widget.matchDetails['lineups'].length > 0
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: ListView.separated(
                  physics: ScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                  padding: EdgeInsets.zero,
                  itemCount: widget.matchDetails['lineups'].length > 0 ? 1 : 0,
                  itemBuilder: (BuildContext context, int index) {
                    int selectedClub = _selectedClub == 1 ? 0 : 1;
                    return Column(
                      children: [
                        for (var key in widget.matchDetails['lineups'][selectedClub]['substitutes'])
                          TeamList(
                            logo: '',
                            name: key['player']['name'],
                            number: key['player']['number'],
                          ),
                      ],
                    );
                  },
                ),
              )
            : Center(
                child: Container(
                  child: Text('No data available'),
                ),
              ),
      ],
    );
  }
}
