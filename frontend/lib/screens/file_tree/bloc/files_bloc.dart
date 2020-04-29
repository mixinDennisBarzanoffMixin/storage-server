import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:file_server_flutter/services/file_service.dart';
import 'package:file_server_flutter/shared/file.dart';
import 'package:meta/meta.dart';

part 'files_event.dart';
part 'files_state.dart';

class FilesBloc extends Bloc<FilesEvent, FilesState> {
  FileService _fileService = FileService();

  String currentDirectory = '/';
  List<File> currentFileList = [];

  @override
  FilesState get initialState => FilesInitial();

  @override
  Stream<FilesState> mapEventToState(
    FilesEvent event,
  ) async* {
    yield FilesLoading();
    try {
      FilesState currentState = state;
      if (event is FileNameEvent) {
        final fileName = "$currentDirectory${event.fileName}";

        if (event is GetFilesEvent) {
          List<File> files = await _fileService.getAtDirectory(fileName);
          if (currentDirectory != event.fileName) {
            currentDirectory += "${event.fileName}/";
          }
          yield FilesAtDirectory(
            files: files,
            directory: currentDirectory, // TODO fix
          );
          currentFileList = files;
        } else if (event is RenameFileEvent) {
          await _fileService.renameFile(
            fileName,
            event.whatToRenameTo,
          );
          // if (currentState is FilesAtDirectory) {
          List<File> updatedFiles = currentFileList.map((file) {
            if (file.name == event.fileName) {
              return File(
                event.whatToRenameTo,
                isDirectory: file.isDirectory,
                lastModified: DateTime.now(),
              );
            } else
              return file;
          }).toList();

          currentFileList = updatedFiles;
          yield FilesAtDirectory(
              files: updatedFiles, directory: currentState.currentDirectory);
        } else if (event is CreateFileEvent) {
          await _fileService.createFile(
            fileName,
            false,
            body: event.content,
          );
          currentFileList.add(File(
            event.fileName,
            isDirectory: false,
            lastModified: DateTime.now(),
          ));
          yield FilesAtDirectory(
            files: currentFileList,
            directory: currentState.currentDirectory,
          );
        } else if (event is CreateDirectoryEvent) {
          await _fileService.createFile(
            fileName,
            true,
          );
          currentFileList.add(
            File(
              event.fileName,
              lastModified: DateTime.now(),
              isDirectory: true,
            ),
          );
          yield FilesAtDirectory(
            files: currentFileList,
            directory: currentDirectory,
          );
        } else if (event is DeleteFileEvent) {
          await _fileService.deleteFile(fileName);
          currentFileList.removeWhere((file) => file.name == event.fileName);
          yield FilesAtDirectory(
            files: currentFileList,
            directory: currentState.currentDirectory,
          );
        }
      } else if (event is GoBackEvent) {
        if (currentDirectory == '/') {
          yield FilesAtDirectory(
            files: currentFileList,
            directory: currentDirectory, // TODO fix
          );
          return;
        }
        currentDirectory = currentDirectory.substring(
            0, currentDirectory.length - 2); // remove last char
        int lastSlash = currentDirectory.lastIndexOf('/');
        currentDirectory = currentDirectory.substring(
            0, lastSlash + 1); // +1 including the slash
        List<File> files = await _fileService.getAtDirectory(currentDirectory);
        yield FilesAtDirectory(
          files: files,
          directory: currentDirectory, // TODO fix
        );
        currentFileList = files;
      }
    } on Exception catch (e) {
      yield FilesError(e.toString());
    }
  }
}
