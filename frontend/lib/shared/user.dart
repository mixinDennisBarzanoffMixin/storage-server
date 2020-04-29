import 'package:flutter/cupertino.dart';

class User {
  String email;
  String displayName;
  User({@required this.email, @required this.displayName});
  User.fromMap(Map<String, dynamic> map)
      : this(
          email: map['email'],
          displayName: map['displayName'],
        );
}
