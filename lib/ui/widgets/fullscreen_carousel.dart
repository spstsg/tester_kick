import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:photo_view/photo_view.dart';

//ignore: must_be_immutable
class FullScreen extends StatefulWidget {
  final String imageUrl;
  List<File> imageFiles;
  List<dynamic> imageStringFiles;
  final int index;
  FullScreen({
    required this.imageUrl,
    required this.imageFiles,
    required this.index,
    this.imageStringFiles: const [],
  });

  @override
  FullScreenState createState() => FullScreenState();
}

class FullScreenState extends State<FullScreen> {
  int carouselItemIndex = 0;
  List imageListFiles = [];

  @override
  void initState() {
    carouselItemIndex = widget.index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0.0,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            MdiIcons.chevronLeft,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Container(
          color: Colors.black,
          child: CarouselSlider.builder(
            options: CarouselOptions(
              height: 600,
              autoPlay: false,
              viewportFraction: 1.0,
              initialPage: widget.index,
              onPageChanged: (index, reason) {
                setState(() {
                  carouselItemIndex = index;
                });
              },
            ),
            itemCount: widget.imageFiles.length > 0
                ? widget.imageFiles.length
                : widget.imageStringFiles.length,
            itemBuilder:
                (BuildContext context, int itemIndex, int pageViewIndex) {
              return MyImageView(
                imageUrl: widget.imageUrl,
                imageFile: widget.imageFiles.length > 0
                    ? widget.imageFiles[itemIndex]
                    : null,
                imageStringFile: widget.imageStringFiles.length > 0
                    ? widget.imageStringFiles[itemIndex]
                    : '',
              );
            },
          ),
        ),
      ),
    );
  }
}

class MyImageView extends StatelessWidget {
  final String imageUrl;
  final File? imageFile;
  final String? imageStringFile;

  MyImageView({required this.imageUrl, this.imageFile, this.imageStringFile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Hero(
        tag: getRandomString(20),
        child: PhotoView(
          imageProvider: imageFile == null
              ? (imageUrl != ''
                  ? NetworkImage(imageUrl)
                  : Image.network(imageStringFile!).image)
              : Image.file(imageFile!).image,
        ),
      ),
    );
  }
}
