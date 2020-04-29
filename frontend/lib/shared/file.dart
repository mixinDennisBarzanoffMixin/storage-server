import 'package:equatable/equatable.dart';

class File extends Equatable {
  final String name;
  final DateTime lastModified;
  final isDirectory;
  const File(this.name, {this.lastModified, this.isDirectory});

  @override
  List<Object> get props => [name, lastModified, isDirectory];
}
