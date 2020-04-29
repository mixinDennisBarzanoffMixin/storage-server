import 'dart:convert';
import 'dart:io';

import 'package:file_server_flutter/shared/file.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FileService {
  final _client = http.Client(); // for multiple requests
  Future<List<File>> getAtDirectory(String directory) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final response = await _client.get(
      'http://100.115.92.198:8080/files?directoryName=$directory',
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader: preferences.get('authToken'),
      },
    );
    switch (response.statusCode) {
      case 200:
        List<dynamic> filesData = jsonDecode(response.body);
        return filesData
            .map(
              (fileData) => File(
                fileData['name'],
                lastModified: DateTime.fromMillisecondsSinceEpoch(
                  fileData['lastModified'],
                ),
                isDirectory: fileData['directory'],
              ),
            )
            .toList();
      default:
        throw Exception('Error ${response.statusCode}');
    }
  }

  Future<void> renameFile(String filePath, String whatToRenameTo) async {
    final response = await _client.put(
      'http://100.115.92.198:8080/files/rename?filePath=$filePath&renameTo=$whatToRenameTo',
      headers: {
        HttpHeaders.authorizationHeader: await _getToken(),
      },
    );
    switch (response.statusCode) {
      case 200:
        return;
      default:
        throw Exception('Error while renaming file: ${response.statusCode}');
    }
  }

  Future<void> createFile(String filePath, bool isDirectory,
      {String body}) async {
    assert((isDirectory && !(body != null)) || (!isDirectory && body != null));
    final response = await _client.post(
      'http://100.115.92.198:8080/files/create?filePath=$filePath&isDirectory=$isDirectory',
      headers: {
        HttpHeaders.authorizationHeader: await _getToken(),
        HttpHeaders.contentTypeHeader: 'text/plain'
      },
      body: body,
    );
    switch (response.statusCode) {
      case 200:
        return;
      default:
        throw Exception('Error while creating file: ${response.statusCode}');
    }
  }

  Future<String> _getToken() {
    return SharedPreferences.getInstance().then(
      (value) => value.get('authToken'),
    );
  }

  Future<void> deleteFile(String filePath) async {
    final response = await _client.post(
      'http://100.115.92.198:8080/files/delete?filePath=$filePath',
      headers: {
        HttpHeaders.authorizationHeader: await _getToken(),
      },
    );
    switch (response.statusCode) {
      case 200:
        return;
      default:
        throw Exception('Error while deleting file: ${response.statusCode}');
    }
  }
}
