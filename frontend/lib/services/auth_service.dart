import 'dart:convert';
import 'dart:io';

import 'package:file_server_flutter/shared/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserAlreadyExistsException {
  UserAlreadyExistsException();
}

class AuthService {
  final client = http.Client(); // for multiple requests

  Stream<User> user$;

  Future<void> signUp({
    @required String email,
    @required String password,
    @required String name,
  }) async {
    final response = await http.post(
      'http://penguin.linux.test:8000/signup',
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    switch (response.statusCode) {
      case 201:
        return;
      case 409:
        throw UserAlreadyExistsException();
        break;
      default:
        throw Exception('Unknown error');
    }
  }

  signIn({
    @required String email,
    @required String password,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      'http://penguin.linux.test:8000/login',
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    print('Auth response:');
    print(response);

    switch (response.statusCode) {
      case 200:
        final authToken = response.headers['Authorization'];
        print(authToken);
        prefs.setString('authToken', authToken);
        return;
      default:
        throw Exception('Unknown error');
    }
  }
}
