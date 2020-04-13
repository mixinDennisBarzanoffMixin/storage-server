import 'package:file_server_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class SignUpFormBloc extends FormBloc<String, String> {
  final emailField = TextFieldBloc(validators: [validateEmailAddress]);
  final passwordField = TextFieldBloc();
  final nameField = TextFieldBloc();

  final _auth = AuthService();

  static String validateEmailAddress(String input) {
    // Maybe not the most robust way of email validation but it's good enough
    const emailRegex =
        r"""^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+""";
    if (RegExp(emailRegex).hasMatch(input)) {
      return null;
    } else {
      return 'Invalid email address';
    }
  }

  SignUpFormBloc() {
    addFieldBlocs(fieldBlocs: [
      emailField,
      passwordField,
      nameField,
    ]);
  }

  @override
  void onSubmitting() async {
    try {
      await _auth.signUp(
        email: emailField.value,
        password: passwordField.value,
        name: nameField.value,
      );

      emitSuccess(canSubmitAgain: true);
    } on UserAlreadyExistsException catch (e) {
      emitFailure(failureResponse: 'This user already exists');
    } catch (e) {
      emitFailure(failureResponse: 'An error has occured');
    }
  }
}

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpFormBloc(),
      child: Builder(
        builder: (context) {
          //ignore: close_sinks
          final formBloc = BlocProvider.of<SignUpFormBloc>(context);

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
              floatingActionButton: FloatingActionButton.extended(
                onPressed: formBloc.submit,
                icon: Icon(Icons.send),
                label: Text('Submit'),
              ),
              body: FormBlocListener<SignUpFormBloc, String, String>(
                onSubmitting: (context, state) {
                  LoadingDialog.show(context);
                },
                onSuccess: (context, state) {
                  LoadingDialog.hide(context);

                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => SignUpSuccessScreen()));
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
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.nameField,
                          decoration: InputDecoration(
                            labelText: 'Display Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
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

class SignUpSuccessScreen extends StatelessWidget {
  const SignUpSuccessScreen({Key key}) : super(key: key);

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
            ],
          ),
        ),
      ),
    );
  }
}
