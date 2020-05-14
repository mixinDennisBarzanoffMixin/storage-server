import 'package:file_server_flutter/screens/file_tree/bloc/files_bloc.dart';
import 'package:file_server_flutter/screens/shared.dart';
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
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/signup': (context) => SignUpScreen(),
          '/signin': (context) => SignInScreen(),
          '/': (context) => FileTree(),
        },
        initialRoute: '/',
        onGenerateRoute: (settings) {
          print('lol');
          print(settings.name);
          final split = settings.name.split('?');
          final withoutArgs = split[0];
          if (withoutArgs == '/shared') {
            print('initializing shared route');
            final token = split[1].split('=')[1];
            // print('args');
//0cbe4077-9e57-413b-b2d3-2a7c54c50101
            print(token);
            return MaterialPageRoute(
                builder: (context) => SharedFiles(token: token));
          }
        },
      ),
    );
  }
}
