import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

import 'bloc/files_bloc.dart';

class CreateFileWidget extends StatefulWidget {
  @override
  _CreateFileWidgetState createState() => _CreateFileWidgetState();
}

class _CreateFileWidgetState extends State<CreateFileWidget> {
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create File'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(
                labelText: 'File name',
              ),
              controller: _nameController,
              autofocus: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                } else if (!RegExp(r"^[\w\-. ]+$").hasMatch(value)) {
                  return 'Not a valid file name';
                }
                return null;
              },
            ),
            SizedBox(height: 30),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'File content',
              ),
              controller: _contentController,
              maxLines: 10,
            ),
            SizedBox(height: 30),
            Builder(
              builder: (context) => RaisedButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false
                  // otherwise.
                  if (_formKey.currentState.validate()) {
                    // If the form is valid, display a Snackbar.
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Processing Data...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    BlocProvider.of<FilesBloc>(context).add(
                      CreateFileEvent(
                        fileName: _nameController.text,
                        content: _contentController.text,
                      ),
                    );
                  }
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
