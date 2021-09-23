import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/widgets/blinking_icon.dart';

class CardEventItem extends StatelessWidget {
  final VoidCallback onTap;

  CardEventItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mSize = MediaQuery.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: mSize.size.width,
        height: 110.0,
        margin: EdgeInsets.only(top: 5.0),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xffEEEEEE),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CardTileTeam(),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'League Name',
                  style: theme.textTheme.headline2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      '0',
                      style: theme.textTheme.headline1,
                    ),
                    Text(
                      '0',
                      style: theme.textTheme.headline1,
                    ),
                  ],
                ),
                Text(
                  'Status',
                  style: theme.textTheme.subtitle2,
                ),
              ],
            ),
            CardTileTeam(),
          ],
        ),
      ),
    );
  }
}

class CardEventItemNew extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSelected;
  final logoHome, logoAway;
  final scoreHome, scoreAway;
  final dateMatch, timeMatch;
  final nameHome, nameAway;
  final shortStatus;
  final timestamp;

  CardEventItemNew({
    required this.onTap,
    this.isSelected = false,
    this.logoHome,
    this.logoAway,
    this.scoreHome,
    this.scoreAway,
    this.dateMatch,
    this.timeMatch,
    this.nameHome,
    this.nameAway,
    this.shortStatus,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final mSize = MediaQuery.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: mSize.size.width,
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            CardTeamNew(
                              logo: logoHome,
                              name: truncateString(nameHome, 20),
                              score: scoreHome,
                            ),
                            SizedBox(height: 10),
                            CardTeamNew(
                              logo: logoAway,
                              name: truncateString(nameAway, 20),
                              score: scoreAway,
                            ),
                            SizedBox(height: 10)
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0),
                            child: Text(
                              matchStatus(shortStatus, timeMatch, timestamp),
                              style: TextStyle(
                                fontSize: 14,
                                color: shortStatus == '1H' ||
                                        shortStatus == '2H' ||
                                        shortStatus == 'ET'
                                    ? ColorPalette.primary
                                    : Colors.black,
                              ),
                            ),
                          ),
                          shortStatus == '1H' ||
                                  shortStatus == '2H' ||
                                  shortStatus == 'ET'
                              ? BlinkingIcon()
                              : SizedBox.shrink()
                        ],
                      )
                    ],
                  ),
                  Divider(height: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardTeamNew extends StatelessWidget {
  final name;
  final logo;
  final score;

  CardTeamNew({required this.name, required this.logo, this.score});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: ColorPalette.white,
            child: ClipOval(
              // child: Image(
              //   height: 30,
              //   width: 30,
              //   image: NetworkImage(logo),
              //   fit: BoxFit.cover,
              // ),
              child: displayImage(logo, 80),
            ),
          ),
          SizedBox(width: 10),
          Container(
            constraints: BoxConstraints(minWidth: 200),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$name',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                score != null
                    ? Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      )
                    : Text(''),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CardHeader extends StatelessWidget {
  final name;
  final logo;

  CardHeader({required this.name, required this.logo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: ColorPalette.primary,
          child: ClipOval(
            // child: Image(
            //   height: 30,
            //   width: 30,
            //   image: NetworkImage(logo),
            //   fit: BoxFit.cover,
            // ),
            child: displayImage(logo, 80),
          ),
        ),
        // displayImage(logo, 80),

        SizedBox(width: 10),
        Text(
          truncateString(name, 40),
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        )
      ],
    );
  }
}

class CardTileTeam extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(
          width: 70.0,
          height: 70.0,
          image: AssetImage(
            'assets/images/barca.png',
          ),
        ),
        SizedBox(
          width: 100.0,
          child: Center(
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Real Madrid Barcelona',
                style: theme.textTheme.subtitle2!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CardChipLeague extends StatelessWidget {
  final onTap;
  final label, image;

  CardChipLeague({
    this.onTap,
    this.label,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
        margin: EdgeInsets.symmetric(horizontal: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            image != null
                ? Image(
                    image: AssetImage(image),
                    width: 26.0,
                    height: 26.0,
                  )
                : Icon(
                    FontAwesomeIcons.futbol,
                    size: 20.0,
                    color: Colors.white,
                  ),
            SizedBox(width: 3.0),
            Text(
              label,
              style: theme.textTheme.subtitle2!.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class CardBarMain extends StatelessWidget {
  final logo, name;
  final bool isDropped;
  final onTap;

  CardBarMain({this.logo, this.name, this.isDropped = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mSize = MediaQuery.of(context);
    final paddingTop = mSize.padding.top;
    return Material(
      color: theme.primaryColorDark,
      child: Container(
        width: mSize.size.width,
        height: 68 + paddingTop,
        padding: EdgeInsets.only(top: paddingTop),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
              child: Image(
                width: 50.0,
                image: AssetImage(logo),
              ),
            ),
            Text(
              name,
              style: theme.textTheme.headline6!.copyWith(color: Colors.white),
            ),
            Spacer(),
            IconButton(
              icon: Icon(
                isDropped
                    ? FontAwesomeIcons.chevronUp
                    : FontAwesomeIcons.chevronDown,
                size: 20.0,
                color: Colors.white,
              ),
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

/// Events Details

class BarEventDetails extends StatelessWidget {
  final logoHome, logoAway;
  final scoreHome, scoreAway;
  final dateMatch, timeMatch;
  final nameHome, nameAway;
  final shortStatus;
  final timestamp;

  BarEventDetails({
    this.logoHome,
    this.logoAway,
    this.scoreHome,
    this.scoreAway,
    this.dateMatch,
    this.timeMatch,
    this.nameHome,
    this.nameAway,
    this.shortStatus,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final mSize = MediaQuery.of(context);
    final theme = Theme.of(context);
    final _paddingTop = mSize.padding.top;

    return FlexibleSpaceBar(
      collapseMode: CollapseMode.none,
      background: Container(
        height: double.infinity,
        color: theme.primaryColorDark,
        padding: EdgeInsets.only(
          top: _paddingTop + 80.0,
          bottom: _paddingTop + 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CardTeamEvent(
              name: nameHome,
              logo: logoHome,
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Text(
                    "${scoreHome == null ? '-' : '$scoreHome'} : ${scoreAway == null ? '-' : '$scoreAway'}",
                    style: GoogleFonts.montserrat(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    matchStatus(shortStatus, timeMatch, timestamp),
                    style: GoogleFonts.montserrat(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            CardTeamEvent(
              logo: logoAway,
              name: nameAway,
            ),
          ],
        ),
      ),
    );
  }
}

class CardTeamEvent extends StatelessWidget {
  final logo;
  final String name;

  CardTeamEvent({required this.logo, required this.name});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Image(
        //   width: 50.0,
        //   height: 50.0,
        //   fit: BoxFit.cover,
        //   image: NetworkImage(logo),
        // ),
        displayImage(logo, 100),
        SizedBox(height: 15),
        SizedBox(
          width: 100.0,
          child: Text(
            name.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class CardBarEvent extends StatelessWidget {
  final logo, name;

  CardBarEvent({
    required this.logo,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.bounceInOut,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                FontAwesomeIcons.chevronLeft,
                size: 20.0,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircleAvatar(
                backgroundColor: ColorPalette.white,
                child: ClipOval(
                    // child: Image(
                    //   height: 30,
                    //   width: 30,
                    //   image: NetworkImage(logo),
                    //   fit: BoxFit.cover,
                    // ),
                    child: displayImage(logo, 80)),
              ),
              // child: displayImage(logo, 30),
            ),
            SizedBox(width: 5.0),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            // Spacer(),
          ],
        ),
      ),
    );
  }
}

class TabTileEvent extends StatelessWidget {
  final label;
  final IconData icon;
  final onTap;
  final bool isSelected;

  TabTileEvent({
    this.label,
    required this.icon,
    this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(5),
              decoration: isSelected
                  ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                    )
                  : null,
              child: Text(
                '$label',
                style: TextStyle(
                  fontSize: isSelected ? 16.0 : 15.0,
                  color: isSelected ? Colors.blue : Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
