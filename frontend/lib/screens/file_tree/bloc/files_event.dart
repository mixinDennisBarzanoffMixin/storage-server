part of 'files_bloc.dart';

@immutable
abstract class FilesEvent {}

class GoBackEvent extends FilesEvent {}

abstract class FileNameEvent extends FilesEvent {
  final String fileName;
  FileNameEvent(this.fileName);
}

class GetFilesEvent extends FileNameEvent {
  GetFilesEvent(String fileName) : super(fileName);
}

class RenameFileEvent extends FileNameEvent {
  final String whatToRenameTo;

  RenameFileEvent({
    @required String fileName,
    @required this.whatToRenameTo,
  }) : super(fileName);
}

class CreateFileEvent extends FileNameEvent {
  final String content;

  CreateFileEvent({
    @required String fileName,
    @required this.content,
  }) : super(fileName);
}

class CreateDirectoryEvent extends FileNameEvent {
  CreateDirectoryEvent({
    @required String fileName,
  }) : super(fileName);
}

class DeleteFileEvent extends FileNameEvent {
  DeleteFileEvent({String fileName}) : super(fileName);
}

class MoveFileEvent extends FileNameEvent {
  final String fileToMoveTo;
  MoveFileEvent({
    @required String fileName,
    @required this.fileToMoveTo,
  }) : super(fileName);
}

class ShareFileEvent extends FileNameEvent {
  ShareFileEvent({@required String fileName}) : super(fileName);
}

class UploadMultipartFileEvent extends FilesEvent {
  final MultipartFile file;
  UploadMultipartFileEvent({@required this.file});
}

class UploadFileEvent extends FilesEvent {
  final String fileName;
  final Uint8List bytes;

  UploadFileEvent({
    @required this.fileName,
    @required this.bytes,
  });
}
