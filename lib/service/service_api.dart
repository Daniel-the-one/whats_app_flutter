import 'dart:convert';
import 'package:whats_app_flutter/model/user.dart';
import 'package:http/http.dart' as http;

class ServiceApi {

  Future <List<User>> getUsers()async{

    final baseUri=Uri.parse("https://dummyjson.com/users");

    final response = await http.get(baseUri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return(data['users'] as List).map((e) => User.fromJson(e),).toList();
    }
    throw Exception('Message ERROR');
  }
}