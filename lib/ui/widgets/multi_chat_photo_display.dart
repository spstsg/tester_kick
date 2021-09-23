import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ChatPhotoGrid extends StatefulWidget {
  final int maxImages;
  final List imageUrls;
  final Function(int) onImageClicked;
  final Function onExpandClicked;
  final String type;

  ChatPhotoGrid({
    required this.imageUrls,
    required this.onImageClicked,
    required this.onExpandClicked,
    required this.type,
    this.maxImages = 4,
  });

  @override
  createState() => _ChatPhotoGridState();
}

class _ChatPhotoGridState extends State<ChatPhotoGrid> {
  @override
  Widget build(BuildContext context) {
    List<Widget> images = buildFileImages();

    return GridView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      children: images,
    );
  }

  List<Widget> buildFileImages() {
    int numImages = widget.imageUrls.length;
    return List<Widget>.generate(min(numImages, widget.maxImages), (index) {
      dynamic imageUrl = widget.imageUrls[index];

      // If its the last image
      if (index == widget.maxImages - 1) {
        // Check how many more images are left
        int remaining = numImages - widget.maxImages;

        // If no more are remaining return a simple image widget
        if (remaining == 0) {
          return GestureDetector(
            child: Hero(
              tag: imageUrl,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.fitHeight,
                height: 200,
                placeholder: (context, url) => Image.asset(
                  'assets/images/img_placeholder'
                  '.png',
                ),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/error_image'
                  '.png',
                ),
              ),
            ),
            onTap: () => widget.onImageClicked(index),
          );
        } else {
          // Create the facebook like effect for the last image with number of remaining  images
          return GestureDetector(
            onTap: () => widget.onExpandClicked(index),
            child: Stack(
              // fit: StackFit.expand,
              children: [
                Hero(
                  tag: imageUrl,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.fitHeight,
                    height: 200,
                    placeholder: (context, url) => Image.asset(
                      'assets/images/img_placeholder'
                      '.png',
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/error_image'
                      '.png',
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '+' + remaining.toString(),
                      style: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        return GestureDetector(
          child: Hero(
            tag: imageUrl,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.fitHeight,
              height: 200,
              placeholder: (context, url) => Image.asset(
                'assets/images/img_placeholder'
                '.png',
              ),
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/error_image'
                '.png',
              ),
            ),
          ),
          onTap: () => widget.onImageClicked(index),
        );
      }
    });
  }
}
