import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/ui/auth/signup/SignUpScreen.dart';

class DynamicLinkService {
  final dynamicLink = FirebaseDynamicLinks.instance;
  late BuildContext _context;

  Future handleDynamicLink() async {
    dynamicLink.onLink(onSuccess: (PendingDynamicLinkData? data) async {
      handleSuccessLinking(data);
    }, onError: (OnLinkErrorException error) async {
      print(error.message.toString());
    });

    final PendingDynamicLinkData? data = await dynamicLink.getInitialLink();
    handleSuccessLinking(data);
  }

  Future<Uri> createDynamicLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://kickchatdev.page.link',
      link: Uri.parse('https://kickchatapp.com/invite'),
      // androidParameters: AndroidParameters(
      //   packageName: 'your_android_package_name',
      //   minimumVersion: 1,
      // ),
      iosParameters: IosParameters(
        bundleId: 'com.kickchatdev.uzochukwu',
        minimumVersion: '1',
        appStoreId: '1477718839', // change later
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Download KickChat',
        description: 'Checkout KickChat app for your smartphone. Download it now from',
        imageUrl: Uri.parse(""), // add kickchat logo here
      ),
    );
    final ShortDynamicLink shortLink = await parameters.buildShortLink();
    return shortLink.shortUrl;
  }

  void handleSuccessLinking(PendingDynamicLinkData? data) {
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      var invite = deepLink.pathSegments.contains('invite');
      if (invite) {
        pushReplacement(this._context, SignUpScreen());
      }
    }
  }
}
