part of 'image_cubit.dart';

@immutable
sealed class ImageState {}

final class ImageInitial extends ImageState {}

final class ImageLoading extends ImageState {}

final class ImageLoaded extends ImageState {
  final File image;
  final String fromFormat;
  final String toFormat;

  ImageLoaded({
    required this.image,
    required this.fromFormat,
    required this.toFormat,
  });

  ImageLoaded copyWith({File? image, String? fromFormat, String? toFormat}) {
    return ImageLoaded(
      image: image ?? this.image,
      fromFormat: fromFormat ?? this.fromFormat,
      toFormat: toFormat ?? this.toFormat,
    );
  }
}

final class ImageFailure extends ImageState {
  final String message;

  ImageFailure({required this.message});
}
