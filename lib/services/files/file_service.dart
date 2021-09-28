import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/main.dart';
import 'package:kick_chat/models/image_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:video_compress/video_compress.dart';

class FileService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  static Reference storage = FirebaseStorage.instance.ref();
  UserService _userService = UserService();
  late StreamController<ImageModel> _userImageStream;
  late StreamSubscription<QuerySnapshot> _userImageSubscription;

  final cloudinary = Cloudinary(
    dotenv.get('CLOUD_API_KEY'),
    dotenv.get('CLOUD_API_SECRET'),
    dotenv.get('CLOUD_NAME'),
  );

  Future<CloudinaryResponse> uploadSingleFile(
    imagePath, [
    publicId = '',
    overwrite = false,
    invalidate = false,
  ]) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadResource(
        CloudinaryUploadResource(filePath: imagePath, resourceType: CloudinaryResourceType.image, optParams: {
          'public_id': publicId,
          'overwrite': overwrite,
          'invalidate': invalidate,
        }),
      );
      return response;
    } catch (e) {
      throw (e);
    }
  }

  Future<List<CloudinaryResponse>> uploadMultipleFiles(imageFileList) async {
    try {
      List<CloudinaryUploadResource> listItems = [];

      for (int i = 0; i < imageFileList.length; i++) {
        listItems.add(CloudinaryUploadResource(
          filePath: imageFileList[i].path,
          resourceType: CloudinaryResourceType.image,
        ));
      }

      List<CloudinaryResponse> responses = await (cloudinary.uploadResources(listItems));
      return responses;
    } catch (e) {
      throw (e);
    }
  }

  Future addUserImageFile(ImageModel image, String url) async {
    try {
      QuerySnapshot imageDoc = await firestore.collection(SOCIAL_FILES).where('userId', isEqualTo: image.userId).get();

      if (imageDoc.docs.isEmpty) {
        ImageModel userImage = ImageModel(
          userId: image.userId,
          profilePicture: image.profilePicture,
          images: [url],
        );
        await firestore.collection(SOCIAL_FILES).doc().set(userImage.toJson()).then((value) => null, onError: (e) => e);
      } else {
        await Future.forEach(imageDoc.docs, (DocumentSnapshot document) async {
          ImageModel imageModel = ImageModel.fromJson(document.data() as Map<String, dynamic>);
          await firestore.doc(document.reference.path).update({
            'profilePicture': image.profilePicture,
            'images': image.images.length > 0 ? [...image.images, ...imageModel.images] : FieldValue.arrayUnion([url])
          });
          if (image.profilePicture.isNotEmpty) {
            DocumentReference<Map<String, dynamic>> updateProfilePic = firestore.collection(USERS).doc(image.userId);
            updateProfilePic.update({'profilePictureURL': image.profilePicture});
          }
          User? user = await _userService.getCurrentUser(MyAppState.currentUser!.userID);
          MyAppState.reduxStore!.dispatch(CreateUserAction(user!));
        });
      }
    } on Exception catch (e) {
      throw e;
    }
  }

  Future<Map> uploadPostVideo(BuildContext context, File video, File thumbnail) async {
    try {
      var uniqueID = Uuid().v4();
      Reference upload = storage.child("flutter/social_network/videos/$uniqueID.mp4");
      SettableMetadata metadata = new SettableMetadata(contentType: 'video');
      UploadTask uploadTask = upload.putFile(video, metadata);
      var storageRef = (await uploadTask.whenComplete(() {})).ref;
      var downloadUrl = await storageRef.getDownloadURL();

      String thumbnailDownloadUrl = await uploadPostVideoThumbnail(thumbnail);
      return {'count': 0, 'url': downloadUrl.toString(), 'mime': 'video', 'videoThumbnail': thumbnailDownloadUrl};
    } catch (e) {
      throw e;
    }
  }

  /// uploads a thumbnail for the video file to firestore storage
  /// @param file the image file of the thumbnail
  /// @return a string of the download url
  Future<String> uploadPostVideoThumbnail(File file) async {
    try {
      var uniqueID = Uuid().v4();
      File compressedImage = await _compressImage(file);
      Reference upload = storage.child("flutter/social_network/video_thumbnails/$uniqueID.png");
      UploadTask uploadTask = upload.putFile(compressedImage);
      var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
      return downloadUrl.toString();
    } catch (e, s) {
      print('FireStoreUtils.uploadPostVideoThumbnail $e $s');
      return 'no_thumbnail';
    }
  }

  Future<File> _compressImage(File file) async {
    File compressedImage = await FlutterNativeImage.compressImage(
      file.path,
      quality: 25,
    );
    return compressedImage;
  }

  /// compress video file to make it load faster but with lower quality,
  /// change the quality parameter to control the quality of the video after
  /// being compressed
  /// @param file the video file that will be compressed
  /// @return File a new compressed file with smaller size
  Future<File> compressVideo(BuildContext context, File file) async {
    int sdkInt = -1;
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      sdkInt = androidInfo.version.sdkInt as int;
    }
    if (VideoCompress.compressProgress$.notSubscribed) {
      await VideoCompress.compressProgress$.subscribe((event) {});
    }
    MediaInfo? mediaInfo = await VideoCompress.compressVideo(
      file.path,
      quality: VideoQuality.MediumQuality,
      deleteOrigin: false,
      includeAudio: true,
    );
    File compressedVideo = File(mediaInfo!.path as String);
    return compressedVideo;
  }

  Stream<ImageModel> getUserImages(String userID) async* {
    _userImageStream = StreamController();
    Stream<QuerySnapshot> result = firestore.collection(SOCIAL_FILES).where('userId', isEqualTo: userID).snapshots();

    _userImageSubscription = result.listen((QuerySnapshot querySnapshot) async {
      if (querySnapshot.docs.isNotEmpty) {
        await Future.forEach(querySnapshot.docs, (DocumentSnapshot image) {
          ImageModel imageModel = ImageModel.fromJson(image.data() as Map<String, dynamic>);
          _userImageStream.sink.add(imageModel);
        });
      } else {
        _userImageStream.sink.add(ImageModel(userId: userID, profilePicture: '', images: []));
      }
    });
    yield* _userImageStream.stream;
  }

  void disposeUserImagesStream() {
    _userImageStream.close();
    _userImageSubscription.cancel();
  }
}
