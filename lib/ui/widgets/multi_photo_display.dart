import 'dart:math';

import 'package:flutter/material.dart';

class PhotoGrid extends StatefulWidget {
  final int maxImages;
  final List imageUrls;
  final Function(int) onImageClicked;
  final Function onExpandClicked;
  final String type;

  PhotoGrid({
    required this.imageUrls,
    required this.onImageClicked,
    required this.onExpandClicked,
    required this.type,
    this.maxImages = 4,
  });

  @override
  createState() => _PhotoGridState();
}

class _PhotoGridState extends State<PhotoGrid> {
  @override
  Widget build(BuildContext context) {
    List<Widget> images = buildFileImages();

    if (widget.imageUrls.length == 1) {
      return GridView(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 500,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        children: images,
      );
    } else if (widget.imageUrls.length == 2) {
      return GridView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: widget.imageUrls.length,
        physics: ScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => widget.onImageClicked(index),
            child: Container(
              child: widget.type == 'file'
                  ? Image.file(
                      widget.imageUrls[index],
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.cover,
                    ),
            ),
          );
        },
      );
    } else {
      return GridView(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 210,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        children: images,
      );
    }
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
            child: widget.type == 'file'
                ? Image.file(imageUrl, fit: BoxFit.cover)
                : Image.network(imageUrl, fit: BoxFit.cover),
            onTap: () => widget.onImageClicked(index),
          );
        } else {
          // Create the facebook like effect for the last image with number of remaining  images
          return GestureDetector(
            onTap: () => widget.onExpandClicked(index),
            child: Stack(
              fit: StackFit.expand,
              children: [
                widget.type == 'file'
                    ? Image.file(imageUrl, fit: BoxFit.cover)
                    : Image.network(imageUrl, fit: BoxFit.cover),
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
          child: widget.type == 'file'
              ? Image.file(imageUrl, fit: BoxFit.cover)
              : Image.network(imageUrl, fit: BoxFit.cover),
          onTap: () => widget.onImageClicked(index),
        );
      }
    });
  }
}
