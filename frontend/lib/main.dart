import 'package:file_server_flutter/screens/file_tree/bloc/files_bloc.dart';
import 'package:file_server_flutter/services/auth_service.dart';
import 'package:file_server_flutter/shared/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:provider/provider.dart';

import 'screens/auth/sign_up.dart';
import 'screens/auth/sign_in.dart';
import 'screens/file_tree/file_tree.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider<FilesBloc>(
          create: (_) => FilesBloc(),
        ),
        StreamProvider<User>.value(
          value: AuthService().user$,
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/signup': (context) => SignUpScreen(),
          '/signin': (context) => SignInScreen(),
          '/files': (context) => FileTree(),
        },
        initialRoute: '/files',
      ),
    );
  }
}
