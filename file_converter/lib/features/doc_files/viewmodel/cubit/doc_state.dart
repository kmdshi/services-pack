part of 'doc_cubit.dart';


abstract class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object?> get props => [];
}

class DocumentInitial extends DocumentState {}

class DocumentLoaded extends DocumentState {
  final File file;
  final String fromFormat;
  final String toFormat;

  const DocumentLoaded({
    required this.file,
    required this.fromFormat,
    required this.toFormat,
  });

  DocumentLoaded copyWith({
    File? file,
    String? fromFormat,
    String? toFormat,
  }) {
    return DocumentLoaded(
      file: file ?? this.file,
      fromFormat: fromFormat ?? this.fromFormat,
      toFormat: toFormat ?? this.toFormat,
    );
  }

  @override
  List<Object?> get props => [file.path, fromFormat, toFormat];
}

class DocumentError extends DocumentState {
  final String message;

  const DocumentError(this.message);

  @override
  List<Object?> get props => [message];
}
