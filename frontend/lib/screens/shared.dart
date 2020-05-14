import 'dart:convert';
import 'dart:io';

import 'package:file_server_flutter/shared/file.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_server_flutter/screens/file_tree/file_tree.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_server_flutter/conf.dart';

class SharedFiles extends StatefulWidget {
  String token;
  SharedFiles({@required this.token});

  @override
  _SharedFilesState createState() => _SharedFilesState();
}

class _SharedFilesState extends State<SharedFiles> {
  List<File> files = [];
  Future<Response> getFile() async {
    try {
      final response = await http.get(
        'http://${config.address}:${config.port}/files/getSharedFile?token=${widget.token}',
        headers: {
          HttpHeaders.authorizationHeader:
              await SharedPreferences.getInstance().then(
            (value) => value.get('authToken'),
          ),
        },
      );
      return response;
    } on SocketException catch (e) {
      print(e.toString());
    }
  }

  Future<void> unshare() async {
    try {
      final response = await http.post(
        'http://${config.address}:${config.port}/files/stopSharing?token=${widget.token}',
        headers: {
          HttpHeaders.authorizationHeader:
              await SharedPreferences.getInstance().then(
            (value) => value.get('authToken'),
          ),
        },
      );
      return response;
    } on SocketException catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final childWidth = size.width / 3;
    final childHeight = childWidth / 4;
    // return Container(color: Colors.red,);
    return FutureBuilder<Response>(
      future: getFile(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(),
            ),
          );
        // Map<String, dynamic> filesData = jsonDecode(snapshot.data.body);
        // List<File> files = filesData
        //     .map(
        //       (fileData) => File(
        //         fileData['name'],
        //         lastModified: DateTime.fromMillisecondsSinceEpoch(
        //           fileData['lastModified'],
        //         ),
        //         isDirectory: fileData['directory'],
        //       ),
        //     )
        //     .toList();
        dynamic data = jsonDecode(snapshot.data.body);
        File file = File(
          data['name'],
          isDirectory: data['isDirectory'] ?? data['directory'],
          lastModified:
              DateTime.fromMillisecondsSinceEpoch(data['lastModified']),
        );
        return Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.link_off),
                onPressed: () {
                  unshare();
                },
              )
            ],
          ),
          body: GridView.count(
            padding: EdgeInsets.symmetric(
              horizontal: getIssuesGridGutter(context),
            ),
            crossAxisCount: getIssueGridCount(context),
            crossAxisSpacing: getIssuesGridGutter(context),
            mainAxisSpacing: getIssuesGridGutter(context),
            childAspectRatio: (childWidth / childHeight),
            children: [
              for (File file in [file])
                FileWidget(
                  file: file,
                ),
            ],
            scrollDirection: Axis.vertical,
          ),
        );
      },
    );
  }
}
