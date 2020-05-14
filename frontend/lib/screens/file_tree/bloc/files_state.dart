part of 'files_bloc.dart';

@immutable
abstract class FilesState {
  final String currentDirectory;

  FilesState(this.currentDirectory);
}

class FilesInitial extends FilesState {
  FilesInitial() : super('');
}

class FilesLoading extends FilesState {
  FilesLoading() : super('');
}

class FilesError extends FilesState {
  final String message;
  FilesError(this.message) : super('');
}

class FilesAtDirectory extends FilesState {
  final List<File> files;
  FilesAtDirectory({
    @required this.files,
    @required String directory,
  }) : super(directory);
}

class LinkFileState extends FilesState {
  final String url;
  LinkFileState({
    @required String currentDirectory,
    @required this.url,
  }) : super(currentDirectory);
}
