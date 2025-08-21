part of 'audio_cubit.dart';

abstract class AudioState extends Equatable {
  const AudioState();

  @override
  List<Object?> get props => [];
}

class AudioInitial extends AudioState {}

class AudioLoaded extends AudioState {
  final File audio;
  final String fromFormat;
  final String toFormat;

  const AudioLoaded({
    required this.audio,
    required this.fromFormat,
    required this.toFormat,
  });

  AudioLoaded copyWith({
    File? audio,
    String? fromFormat,
    String? toFormat,
  }) {
    return AudioLoaded(
      audio: audio ?? this.audio,
      fromFormat: fromFormat ?? this.fromFormat,
      toFormat: toFormat ?? this.toFormat,
    );
  }

  @override
  List<Object?> get props => [audio.path, fromFormat, toFormat];
}

class AudioError extends AudioState {
  final String message;

  const AudioError(this.message);

  @override
  List<Object?> get props => [message];
}
