// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';

class UpcomingAudioCard extends StatelessWidget {
  const UpcomingAudioCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: ColorPalette.greyWhite),
      child: Card(
        elevation: 1.0,
        margin: EdgeInsets.only(
          top: 10,
          left: 10,
          right: 10,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: ColorPalette.grey, width: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.only(
            top: 12,
            bottom: 10,
            left: 15,
            right: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 1.0,
                        vertical: 1.0,
                      ),
                      child: Text(
                        'Today,',
                        style: TextStyle(
                          color: ColorPalette.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 1.0,
                      ),
                      child: Text(
                        '6:30 PM',
                        style: TextStyle(
                          color: ColorPalette.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.0,
                        vertical: 1.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.blueAccent),
                      ),
                      child: Text(
                        '#chelsea',
                        style: TextStyle(color: ColorPalette.black),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.0,
                        vertical: 1.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.blueAccent),
                      ),
                      child: Text(
                        '#arsenal',
                        style: TextStyle(color: ColorPalette.black),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.0,
                        vertical: 1.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.blueAccent),
                      ),
                      child: Text(
                        '#EPL',
                        style: TextStyle(color: ColorPalette.black),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: Text(
                  'Ringer NBA: Trade Rumbings, Mock Draft, Sleepers',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: ColorPalette.primary,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Kevin James, Uzochukwu Eddie Odozi, Sammy Daniel',
                        style: TextStyle(
                          color: ColorPalette.black,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'The worlds most ethical college football podcast is here to get down and dirty. We will discuss everything related to college football. Join us and let us have this wonderful discussion.',
                        style: TextStyle(
                          color: ColorPalette.grey,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
