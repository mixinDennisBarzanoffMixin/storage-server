import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:file_server_flutter/conf.dart';
import 'package:file_server_flutter/services/file_service.dart';
import 'package:file_server_flutter/shared/file.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
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
            files: updatedFiles,
            directory: currentState.currentDirectory,
          );
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
        } else if (event is MoveFileEvent) {
          final fileName = '$currentDirectory${event.fileName}';
          final directoryToMoveTo =
              '$currentDirectory${event.fileToMoveTo}/${event.fileName}';
          await _fileService.moveFile(fileName, directoryToMoveTo);
          currentFileList.removeWhere((file) => file.name == event.fileName);
          yield FilesAtDirectory(
            files: currentFileList,
            directory: currentState.currentDirectory,
          );
        } else if (event is ShareFileEvent) {
          final fileName = '$currentDirectory${event.fileName}';
          final token = await _fileService.shareFile(fileName);
          final url =
              'http://${config.address}:${config.port}/#/shared?token=$token';
          print('token : $url');
          yield LinkFileState(currentDirectory: currentDirectory, url: url);

          yield FilesAtDirectory(
              files: currentFileList, directory: currentDirectory);
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
      } else if (event is UploadMultipartFileEvent) {
        await _fileService.uploadMultipartFile(event.file, currentDirectory);
        yield FilesAtDirectory(
          directory: currentDirectory,
          files: currentFileList
            ..add(
              File(
                event.file.filename,
                isDirectory: false,
                lastModified: DateTime.now(),
              ),
            ),
        );
      } else if (event is UploadFileEvent) {
        await _fileService.uploadFile(event.fileName, event.bytes, currentDirectory);
        yield FilesAtDirectory(
          directory: currentDirectory,
          files: currentFileList
            ..add(
              File(
                event.fileName,
                isDirectory: false,
                lastModified: DateTime.now(),
              ),
            ),
        );
      }
    } on Exception catch (e) {
      yield FilesError(e.toString());
    }
  }
}
