
import 'package:equatable/equatable.dart';

enum SourceType { file, url, text }
enum ProcessingStatus { pending, processing, completed, error }

class PersonalDocumentEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final SourceType sourceType;
  final String originalSource;
  final String? extractedTextUrl;
  final String? generatedAudioUrl;
  final ProcessingStatus status;
  final DateTime createdAt;

  const PersonalDocumentEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.sourceType,
    required this.originalSource,
    this.extractedTextUrl,
    this.generatedAudioUrl,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, title, sourceType, originalSource, extractedTextUrl, generatedAudioUrl, status, createdAt];
}