import 'dart:convert';
import 'dart:io';

import 'package:file_server_flutter/shared/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../conf.dart';

class UserAlreadyExistsException {
  UserAlreadyExistsException();
}

extension on String {
  User toUser() {
    Map<String, dynamic> tokenData = Jwt.parseJwt(
      this.replaceFirst('Bearer ', ''),
    );
    tokenData['displayName'] = tokenData['sub'];
    tokenData['email'] =
        tokenData['sub']; // workaround for server not providing these
    return User.fromMap(
      tokenData,
    );
  }
}

class AuthService {
  final _client = http.Client(); // for multiple requests

  Subject<User> userSubject;
  Stream<User> user$;
  static final AuthService _instance = AuthService._();

  AuthService._() {
    userSubject = ReplaySubject(maxSize: 1);
    user$ =
        _getSavedUser().asStream().concatWith([userSubject]).doOnData((event) {
      print('NEW DATA AUTH');
      print(event.email);
    });
  }

  factory AuthService() {
    return _instance;
  }

  Stream<bool> loggedIn() {
    return userSubject.map((event) => event != null); // TODO ask server
  }

  Future<String> _getSavedToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('authToken');
  }

  Future<User> _getSavedUser() async {
    // TODO test
    String token =
        await _getSavedToken(); // null will disregard the second observable
    return token?.toUser();
  }

  Future<void> signUp({
    @required String email,
    @required String password,
    @required String name,
  }) async {
    final response = await _client.post(
      'http://${config.address}:${config.port}/signup',
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

    final response = await _client.post(
      'http://${config.address}:${config.port}/login',
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
        print('success');
        final authToken = response.headers['authorization'];
        print(response.headers);
        print(authToken);
        prefs.setString('authToken', authToken);
        userSubject.add(authToken.toUser());
        return;
      default:
        throw Exception('Unknown error');
    }
  }

  Future<void> signout() async {
    userSubject.add(null);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('authToken');
  }
}
