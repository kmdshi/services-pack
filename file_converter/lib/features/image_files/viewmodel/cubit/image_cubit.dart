import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:saver_gallery/saver_gallery.dart';

part 'image_state.dart';

class ImageCubit extends Cubit<ImageState> {
  ImageCubit() : super(ImageInitial());

  Future<void> setImage(File imageFile) async {
    final format = _getImageFormat(imageFile);
    final defaultToFormat = [
      'JPG',
      'PNG',
      'WEBP',
    ].firstWhere((f) => f.toLowerCase() != format.toLowerCase());

    emit(
      ImageLoaded(
        image: imageFile,
        fromFormat: format,
        toFormat: defaultToFormat,
      ),
    );
  }

  void setToFormat(String fromFormat, String toFormat) {
    final currentState = state;
    if (currentState is ImageLoaded) {
      emit(currentState.copyWith(fromFormat: fromFormat, toFormat: toFormat));
    }
  }

  Future<String?> convertImage() async {
    try {
      final currentState = state;
      if (currentState is! ImageLoaded) return null;

      final imageFile = currentState.image;
      final format = currentState.toFormat.toLowerCase();
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      List<int> encoded;
      String ext;

      switch (format) {
        case 'png':
          encoded = img.encodePng(image);
          ext = 'png';
          break;
        case 'jpg':
          encoded = img.encodeJpg(image);
          ext = 'jpg';
          break;
        case 'webp':
          encoded = (await FlutterImageCompress.compressWithFile(
            imageFile.path,
            format: CompressFormat.webp,
          ))!;
          ext = 'webp';
          break;
        default:
          return null;
      }

      final tempFile = File(
        '${Directory.systemTemp.path}/converted_image.$ext',
      );
      await tempFile.writeAsBytes(encoded);

  
      await SaverGallery.saveImage(
        await tempFile.readAsBytes(),
        quality: 100,
        fileName: 'converted_image',
        androidRelativePath: "Pictures/appName/images",
        skipIfExists: false,
      );

      emit(
        currentState.copyWith(
          image: tempFile,
          fromFormat: currentState.toFormat,
          toFormat: format,
        ),
      );

      return tempFile.path;
    } catch (e) {
      emit(ImageFailure(message: e.toString()));
    }
    return null;
  }

  String _getImageFormat(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    if (ext.contains('jpg') || ext.contains('jpeg')) return 'JPG';
    if (ext.contains('png')) return 'PNG';
    if (ext.contains('webp')) return 'WEBP';
    return 'UNKNOWN';
  }
}
