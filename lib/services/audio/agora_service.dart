import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class AgoraService {
  String baseUrl = 'https://kickchat-agora-token.vercel.app/access_token';

  Future getToken(String channelName, String role, int uid) async {
    final response = await http.get(
      Uri.parse('$baseUrl?channelName=$channelName&role=$role&uid=$uid'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['token'];
    } else {
      throw 'Failed to fetch the token';
    }
  }
}
