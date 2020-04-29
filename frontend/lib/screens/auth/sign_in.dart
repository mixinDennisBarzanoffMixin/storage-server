import 'package:file_server_flutter/screens/file_tree/file_tree.dart';
import 'package:file_server_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class SignInFormBloc extends FormBloc<String, String> {
  final emailField = TextFieldBloc();
  final passwordField = TextFieldBloc();

  final _auth = AuthService();

  SignInFormBloc() {
    addFieldBlocs(fieldBlocs: [
      emailField,
      passwordField,
    ]);
  }

  void addErrors() {
    emailField.addError('Awesome Error!');
  }

  @override
  void onSubmitting() async {
    try {
      await _auth.signIn(
        email: emailField.value,
        password: passwordField.value,
      );

      emitSuccess(canSubmitAgain: true);
    } on UserAlreadyExistsException {
      emitFailure(failureResponse: 'This user already exists');
    } catch (e) {
      emitFailure(failureResponse: 'An error has occured');
    }
  }
}

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignInFormBloc(),
      child: Builder(
        builder: (context) {
          //ignore: close_sinks
          final formBloc = BlocProvider.of<SignInFormBloc>(context);

          return Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            child: Scaffold(
              appBar: AppBar(title: Text('Built-in Widgets')),
              floatingActionButton: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FloatingActionButton.extended(
                    onPressed: formBloc.submit,
                    icon: Icon(Icons.send),
                    label: Text('Login'),
                  ),
                ],
              ),
              body: FormBlocListener<SignInFormBloc, String, String>(
                onSubmitting: (context, state) {
                  LoadingDialog.show(context);
                },
                onSuccess: (context, state) {
                  LoadingDialog.hide(context);

                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => FileTree()));
                },
                onFailure: (context, state) {
                  LoadingDialog.hide(context);

                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text(state.failureResponse)));
                },
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: <Widget>[
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.emailField,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.passwordField,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          suffixButton: SuffixButton.obscureText,
                        ),
                        FlatButton(
                          child: Text('Sign Up'),
                          onPressed: () => {
                            Navigator.pushReplacementNamed(context, '/signup')
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  static void show(BuildContext context, {Key key}) => showDialog<void>(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (_) => LoadingDialog(key: key),
      ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));

  static void hide(BuildContext context) => Navigator.pop(context);

  LoadingDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Card(
          child: Container(
            width: 80,
            height: 80,
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[300],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text('A confirmation email has been sent to you!'),
              Icon(
                Icons.sentiment_satisfied,
                size: 100,
              ),
              RaisedButton(
                color: Colors.green[100],
                child: Text('Sign out'),
                onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => SignInScreen())),
              )
            ],
          ),
        ),
      ),
    );
  }
}
