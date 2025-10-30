import 'package:equatable/equatable.dart';

class PersonalDocumentEntity extends Equatable {
  final String id;
  final String name;
  final String filePath;
  final DateTime createdAt;

  const PersonalDocumentEntity({
    required this.id,
    required this.name,
    required this.filePath,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, filePath, createdAt];
}
