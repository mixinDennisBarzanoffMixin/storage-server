import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_server_flutter/shared/file.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../conf.dart';

class FileService {
  final _client = http.Client(); // for multiple requests
  final _dio = Dio();
  Future<List<File>> getAtDirectory(String directory) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final response = await _client.get(
      'http://${config.address}:${config.port}/files?directoryName=$directory',
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
      'http://${config.address}:${config.port}/files/rename?filePath=$filePath&renameTo=$whatToRenameTo',
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
      'http://${config.address}:${config.port}/files/create?filePath=$filePath&isDirectory=$isDirectory',
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
      'http://${config.address}:${config.port}/files/delete?filePath=$filePath',
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

  Future<void> moveFile(String fileName, String pathToMoveTo) async {
    final response = await _client.post(
      'http://${config.address}:${config.port}/files/move?filePath=$fileName&filePathToMoveTo=$pathToMoveTo',
      headers: {
        HttpHeaders.authorizationHeader: await _getToken(),
      },
    );
    switch (response.statusCode) {
      case 200:
        return;
      default:
        throw Exception('Error while moving file: ${response.statusCode}');
    }
  }

  Future<String> shareFile(String fileName) async {
    final response = await _client.post(
      'http://${config.address}:${config.port}/files/share?filePath=$fileName',
      headers: {
        HttpHeaders.authorizationHeader: await _getToken(),
      },
    );
    switch (response.statusCode) {
      case 200:
        return response.body;
      default:
        throw Exception('Error while sharing: ${response.statusCode}');
    }
  }

  Future<String> unshareFile(String token) async {
    final response = await _client.post(
      'http://${config.address}:${config.port}/files/stopSharing?token=$token',
      headers: {
        HttpHeaders.authorizationHeader: await _getToken(),
      },
    );
    switch (response.statusCode) {
      case 200:
        return response.body;
      default:
        throw Exception('Error while sharing: ${response.statusCode}');
    }
  }

  Future<void> uploadMultipartFile(
      http.MultipartFile file, String directory) async {
    try {
      // String fileName = file.filename;
      final url =
          'http://${config.address}:${config.port}/files/upload?directoryName=$directory';
      // FormData formData = FormData.fromMap({
      //   "file": file
      //   // await MultipartFile.fromFile(file.path, filename:fileName),
      // });
      // final response = await _dio.post(url, data: formData);
      // print(file.toString());
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      )
        ..headers.addAll({
          HttpHeaders.authorizationHeader: await _getToken(),
        })
        ..files.add(file);
      final response = await request.send();
      switch (response.statusCode) {
        case 200:
          return;
        default:
          throw Exception('Error while sending file: ${response.statusCode}');
      }
    } on Exception catch (e) {
      rethrow;
    }
  }

  Future<void> uploadFile(
      String fileName, Uint8List bytes, String directory) async {
    try {
      // String fileName = file.filename;
      final url =
          'http://${config.address}:${config.port}/files/upload?directoryName=$directory';
      FormData formData = FormData.fromMap({
        "file": MultipartFile.fromBytes(bytes, filename: fileName),
      });
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {HttpHeaders.authorizationHeader: await _getToken()},
        ),
      );
      // print(file.toString());
      // final request = http.MultipartRequest(
      //   'POST',
      //   Uri.parse(url
      //       ),
      // )
      //   ..headers.addAll({
      //     HttpHeaders.authorizationHeader: await _getToken(),
      //   })
      //   ..fields['file'] = file;
      // ..files.add(file);
      // final response = await request.send();
      switch (response.statusCode) {
        case 200:
          return;
        default:
          throw Exception('Error while sending file: ${response.statusCode}');
      }
    } on Exception catch (e) {
      rethrow;
    }
  }
}
