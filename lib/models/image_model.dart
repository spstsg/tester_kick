class ImageModel {
  String userId;
  String profilePicture;
  List images;

  ImageModel({
    this.userId = '',
    this.profilePicture = '',
    this.images = const [],
  });

  factory ImageModel.fromJson(Map<String, dynamic> parsedJson) {
    List _images = parsedJson['images'] ?? [''];
    return new ImageModel(
      userId: parsedJson['userId'] ?? '',
      profilePicture: parsedJson['profilePicture'] ?? '',
      images: _images,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": this.userId,
      'profilePicture': this.profilePicture,
      'images': this.images,
    };
  }
}
