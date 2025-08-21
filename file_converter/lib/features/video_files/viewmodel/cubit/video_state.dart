part of 'video_cubit.dart';

abstract class VideoState extends Equatable {
  const VideoState();

  @override
  List<Object?> get props => [];
}

class VideoInitial extends VideoState {}

class VideoLoaded extends VideoState {
  final File video;
  final String fromFormat;
  final String toFormat;

  const VideoLoaded({
    required this.video,
    required this.fromFormat,
    required this.toFormat,
  });

  VideoLoaded copyWith({File? video, String? fromFormat, String? toFormat}) {
    return VideoLoaded(
      video: video ?? this.video,
      fromFormat: fromFormat ?? this.fromFormat,
      toFormat: toFormat ?? this.toFormat,
    );
  }

  @override
  List<Object?> get props => [video.path, fromFormat, toFormat];
}

class VideoError extends VideoState {
  final String message;

  const VideoError(this.message);

  @override
  List<Object?> get props => [message];
}
