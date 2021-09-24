import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:photo_view/photo_view.dart';
import 'package:carousel_slider/carousel_slider.dart';

// ignore: must_be_immutable
class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final List<File> imageFiles;
  List<dynamic> imageStringFiles;
  final int index;

  FullScreenImageViewer({
    required this.imageUrl,
    this.imageFiles: const [],
    this.imageStringFiles: const [],
    this.index: 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0.0,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Container(
          color: Colors.black,
          child: CarouselSlider.builder(
            options: CarouselOptions(
              height: 600,
              autoPlay: false,
              viewportFraction: 1.0,
              initialPage: index,
            ),
            itemCount: imageStringFiles.length > 0
                ? imageStringFiles.length
                : (imageFiles.length > 0 ? imageFiles.length : 0),
            itemBuilder:
                (BuildContext context, int itemIndex, int pageViewIndex) {
              return Container(
                child: Hero(
                  tag: getRandomString(20),
                  child: PhotoView(
                    imageProvider: imageFiles.length == 0
                        ? (imageUrl != ''
                            ? NetworkImage(imageUrl)
                            : Image.network(imageStringFiles[itemIndex]).image)
                        : Image.file(imageFiles[itemIndex]).image,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
