import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String kickchatBackendUrl = dotenv.get('KICK_CHAT_BACKEND_URL');

class AgoraService {
  String baseUrl = '$kickchatBackendUrl/access_token';

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
