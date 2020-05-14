import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:file_server_flutter/services/auth_service.dart';
import 'package:file_server_flutter/shared/file.dart';
import 'package:file_server_flutter/shared/layout_breakpoints.dart';
import 'package:file_server_flutter/shared/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:responsive_scaffold/responsive_scaffold.dart';
import 'package:rxdart/rxdart.dart';

import '../shared.dart';
import 'bloc/files_bloc.dart';
import 'create_file.dart';

class FileTree extends StatefulWidget {
  @override
  _FileTreeState createState() => _FileTreeState();
}

class _FileTreeState extends State<FileTree> {
  AuthService _auth = AuthService();
  final _dragSubject = BehaviorSubject<File>();

  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<FilesBloc>(context).add(GetFilesEvent('/'));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      kDesktopBreakpoint: 1200,
      title: Text('Personal storage'),
      drawer: Drawer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  FlutterLogo(size: 44),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Your drive',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.cloud),
                    title: Text('My drive'),
                  ),
                  ListTile(
                    leading: Icon(Icons.people),
                    title: Text('Shared with me'),
                    onTap: () async {
                      String token = await showDialog<String>(
                        context: context,
                        builder: (context) => InputNameDialog(
                          title: Text('Enter new token'),
                        ),
                      );
                      Navigator.pop(context);
                      if (token != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SharedFiles(
                              token: token,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      trailing: StreamBuilder(
        stream: _auth.loggedIn(),
        builder: (context, isLoggedInSnapshot) {
          if (isLoggedInSnapshot.hasData && isLoggedInSnapshot.data == true) {
            // logged in
            return PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: LogoutButton(),
                ),
              ],
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 20,
                child: Text(getFirstLetterOfName(context).toUpperCase()),
              ),
            );
          } else
            return LoginButton();
        },
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Scrollbar(
          child: BlocConsumer<FilesBloc, FilesState>(
            listener: (context, state) async {
              print(state);
              print(state.runtimeType);
              if (state is FilesLoading) {
                setState(() {
                  _isLoading = true;
                });
                return;
              } else if (state is FilesError) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
              } else if (state is LinkFileState) {
                print('link file state in consumer');
                print(state.url);
                Clipboard.setData(ClipboardData(text: state.url));
                // await ClipboardManager.copyToClipBoard(state.url);
                final snackBar = SnackBar(
                  content: Text('Link copied to clipboard'),
                );
                Scaffold.of(context).showSnackBar(snackBar);
              }
              setState(() {
                _isLoading = false;
              });
            },
            buildWhen: (prevState, currState) => currState is FilesAtDirectory,
            builder: (context, state) {
              final size = MediaQuery.of(context).size;
              final childWidth = size.width / 3;
              final childHeight = childWidth / 4;
              return Column(
                children: <Widget>[
                  if (state is FilesAtDirectory) ...[
                    AppBar(
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          BlocProvider.of<FilesBloc>(context)
                              .add(GoBackEvent());
                        },
                      ),
                      title: Text(
                        state.currentDirectory,
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: GridView.count(
                        padding: EdgeInsets.symmetric(
                          horizontal: getIssuesGridGutter(context),
                        ),
                        crossAxisCount: getIssueGridCount(context),
                        crossAxisSpacing: getIssuesGridGutter(context),
                        mainAxisSpacing: getIssuesGridGutter(context),
                        childAspectRatio: (childWidth / childHeight),
                        children: [
                          for (File file in state.files)
                            FileWidget(
                              file: file,
                              dragSubject: _dragSubject,
                            ),
                        ],
                        scrollDirection: Axis.vertical,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: Builder(
          builder: (context) => FloatingActionButton(
            child: Icon(Icons.add),
            tooltip: 'Add File',
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) => AddFileBottomSheet(),
              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.only(
              //     topLeft: Radius.circular(10),
              //     topRight: Radius.circular(10),
              //   ),
              // ),
              // backgroundColor: Colors.transparent,
              isScrollControlled: true,
            ),
          ),
        ),
      ),
    );
  }

  String getFirstLetterOfName(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user != null)
      return user.displayName.substring(0, 1);
    else
      return 'None';
  }
}

int getIssueGridCount(BuildContext context) {
  ScreenSize size = getScreenSizeFrom(context);
  switch (size) {
    case ScreenSize.small:
      return 1;
    case ScreenSize.medium:
      return 2;
    case ScreenSize.large:
      return 3;
  }
}

double getIssuesGridGutter(BuildContext context) {
  ScreenSize size = getScreenSizeFrom(context);
  switch (size) {
    case ScreenSize.small:
      return 16;
    case ScreenSize.medium:
    case ScreenSize.large:
      return 24;
  }
}

class AddFileBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;
    final isTablet = width >= 700 && width < 1400;
    double padding;
    if (isMobile)
      padding = 0;
    else if (isTablet)
      padding = 180;
    else
      padding = 400;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        // backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
              alignment: Alignment.center,
              child: Text(
                'Create New File',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              children: [
                _gridTile(
                  context: context,
                  icon: Icon(Icons.file_upload),
                  text: 'Upload file',
                  callback: () async {
                    FilePickerCross filePicker = FilePickerCross();
                    await filePicker.pick();

                    String fileName = await showDialog<String>(
                      context: context,
                      builder: (context) => InputNameDialog(
                        title: Text('Enter new name'),
                      ),
                    );
                    if (fileName != null) {
                      var file = filePicker.toMultipartFile(filename: fileName);
                      BlocProvider.of<FilesBloc>(context).add(
                        UploadMultipartFileEvent(file: file),
                      );
                      Navigator.pop(context);
                    }
                    // Navigator.pop(context);
                  },
                ),
                _gridTile(
                  context: context,
                  icon: Icon(Icons.create),
                  text: 'Create text file',
                  callback: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CreateFileWidget(),
                    ),
                  ),
                ),
                _gridTile(
                  context: context,
                  icon: Icon(Icons.folder_open),
                  text: 'Create directory',
                  callback: () async {
                    String newName = await showDialog<String>(
                      context: context,
                      builder: (context) => InputNameDialog(
                        title: Text('Enter new directory name'),
                      ),
                    );
                    if (newName != null) {
                      BlocProvider.of<FilesBloc>(context).add(
                        CreateDirectoryEvent(
                          fileName: newName,
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridTile({
    @required BuildContext context,
    @required Icon icon,
    @required String text,
    @required void callback(),
  }) {
    return Material(
      // shape: CircleBorder(),
      // color: Colors.yellow,
      child: InkWell(
        onTap: () => callback(),
        child: Container(
          padding: EdgeInsets.all(15),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              icon,
              SizedBox(
                height: 7,
              ),
              Text(text, style: Theme.of(context).textTheme.subtitle2),
            ],
          ),
        ),
      ),
    );
  }
}

class FileWidget extends StatelessWidget {
  final File file;
  final BehaviorSubject<File> dragSubject;

  const FileWidget({
    Key key,
    @required this.file,
    this.dragSubject,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Widget fileNameWidget = Text(this.file.name);
    Widget lastModifiedWidget = Text(
      this.file.lastModified.toString(),
    );
    double elevation = this.file.isDirectory ? 1.0 : 0.0;
    Icon fileIcon =
        Icon(this.file.isDirectory ? Icons.folder : Icons.insert_drive_file);

    final draggable = Draggable<File>(
      feedback: Material(
        elevation: 2,
        child: Container(
          width: 200,
          child: ListTile(
            leading: fileIcon,
            title: fileNameWidget,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: this,
      ),
      data: file,
      // onDragEnd: (details) => print(details.wasAccepted),
      child: StreamBuilder<File>(
          stream: dragSubject,
          builder: (context, snapshot) {
            final showBorder = snapshot.data == file;
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: showBorder
                      ? Colors.blue
                      : Theme.of(context).scaffoldBackgroundColor,
                  width: 5,
                ),
              ),
              child: Card(
                elevation: elevation,
                child: Center(
                  child: ListTile(
                    leading: fileIcon,
                    title: fileNameWidget,
                    subtitle: lastModifiedWidget,
                    trailing: IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        builder: (context) => OptionsBottomSheet(file: file),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
    return GestureDetector(
      onDoubleTap: () {
        BlocProvider.of<FilesBloc>(context).add(
          GetFilesEvent(file.name),
        );
      },
      child: DragTarget<File>(
        onWillAccept: (file) {
          print('${this.file.name} is under ${file.name}');
          final willAccept = this.file.isDirectory && this.file != file;
          if (willAccept) {
            dragSubject.add(this.file);
          }
          return willAccept;
        }, // files can only be placed in directories
        onLeave: (file) {
          dragSubject.add(null);
        },
        onAccept: (file) {
          dragSubject.add(null);
          BlocProvider.of<FilesBloc>(context).add(
            MoveFileEvent(
              fileName: file.name,
              fileToMoveTo: this.file.name,
            ),
          );
          print('moved file');
          print('accepting ${file.name}');
        }, // TODO Bloc.movefile,
        builder: (context, candidateData, rejectedData) => draggable,
      ),
    );
  }
}

class OptionsBottomSheet extends StatelessWidget {
  final File file;
  const OptionsBottomSheet({
    Key key,
    @required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Edit name'),
          onTap: () async {
            String newName = await showDialog<String>(
              context: context,
              builder: (context) => InputNameDialog(
                title: Text('Enter new name'),
              ),
            );
            if (newName != null) {
              BlocProvider.of<FilesBloc>(context).add(
                RenameFileEvent(
                  fileName: file.name,
                  whatToRenameTo: newName,
                ),
              );
            }
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.link),
          title: Text("Share file"),
          onTap: () async {
            BlocProvider.of<FilesBloc>(context).add(
              ShareFileEvent(fileName: file.name),
            );
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: Icon(Icons.delete),
          title: Text('Delete file'),
          onTap: () async {
            bool shouldDelete = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Confirm delete'),
                content:
                    Text('Are you sure you want to delete "${file.name}"?'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            );
            if (shouldDelete) {
              BlocProvider.of<FilesBloc>(context).add(
                DeleteFileEvent(fileName: file.name),
              );
            }
            Navigator.of(context);
          },
        )
      ],
    );
  }
}

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text('Login'),
      onPressed: () {
        Navigator.pushNamed(context, '/signin');
      },
    );
  }
}

class LogoutButton extends StatelessWidget {
  final AuthService auth = AuthService();
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text('Logout'),
      onPressed: () {
        auth.signout();
      },
    );
  }
}

class InputNameDialog extends StatefulWidget {
  final Widget title;
  InputNameDialog({@required this.title});
  @override
  _InputNameDialogState createState() => _InputNameDialogState();
}

class _InputNameDialogState extends State<InputNameDialog> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      content: Container(
        child: TextFormField(
          onFieldSubmitted: (value) => submitText(),
          autofocus: true,
          controller: _nameController,
        ),
      ),
      actions: [
        FlatButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        FlatButton(
          child: Text('Ok'),
          onPressed: () => submitText(),
        ),
      ],
    );
  }

  void submitText() {
    Navigator.of(context).pop(_nameController.text);
  }
}
