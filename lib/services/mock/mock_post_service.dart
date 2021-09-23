import 'package:destiny/destiny.dart';
import 'package:kick_chat/models/post_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/post/post_service.dart';

class MockPostService {
  PostService _postService = PostService();

  generatePosts() async {
    final avatarProfileColor = avatarColor();

    User user = User(
      username: 'Sunny',
      email: 'sunny@test.com',
      password: 'qwerty1@',
      dob: '1977-09-18 00:00:00.000',
      phoneNumber: '',
      profilePictureURL: 'https://res.cloudinary.com/ratingapp/image/upload/sunny',
      lowercaseUsername: 'sunny',
      userID: 'DFdraOQMlWc1DGC9cV0E5PHdf6F2',
      uniqueId: 240195658,
      active: true,
      fcmToken:
          'enW_Bq9hyUAqnr3Qwy9etr:APA91bEYgpPkFYW_9dTwLDC9e75YQQcLr-iePSP-JEO-8IQH-g6CnFviyyUIAeeQVm0EW7RK0rE-bRthK1UN4b55zX_x0jktf8fo7AhQZEkeCC-K3rvOHVU-uSjUW6SvVcL5qGR2kJXH',
      postCount: 0,
      followersCount: 0,
      followingCount: 0,
      avatarColor: '#e91e63',
      bio: '',
      team: 'Arsenal F.C.',
      lowercaseTeam: 'arsenal f.c.',
    );

    Post post = Post(
      author: user,
      authorId: 'DFdraOQMlWc1DGC9cV0E5PHdf6F2',
      username: 'Sunny',
      email: 'sunny@test.com',
      avatarColor: '#e91e63',
      profilePicture: 'https://res.cloudinary.com/ratingapp/image/upload/sunny',
      bgColor: avatarProfileColor,
      reactions: PostReactions(),
      post: Destiny.string(20),
      gifUrl: '',
      privacy: 'Public',
      postMedia: [],
    );
    await _postService.publishPost(post);
  }
}
