import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:wanderlust/CHATBOT/constants/api_consts.dart';
import 'package:wanderlust/CHATBOT/models/chat_model.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Send Message using ChatGPT API
  static Future<List<ChatModel>> sendMessageGPT(
      {required String message, required String modelId}) async {
    try {
      log("modelId $modelId");
      var response = await http.post(
        Uri.parse("$BASE_URL/chat/completions"),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "model": modelId,
            "messages": [
              {
                "role": "user",
                "content": message,
              }
            ]
          },
        ),
      );

      // Map jsonResponse = jsonDecode(response.body);
      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      List<ChatModel> chatList = [];
      if (jsonResponse["choices"].length > 0) {
        // log("jsonResponse[choices]text ${jsonResponse["choices"][0]["text"]}");
        chatList = List.generate(
          jsonResponse["choices"].length,
          (index) => ChatModel(
            msg: jsonResponse["choices"][index]["message"]["content"],
            chatIndex: 1,
          ),
        );
      }
      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }
}
