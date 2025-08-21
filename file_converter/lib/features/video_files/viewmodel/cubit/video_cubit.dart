import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:path/path.dart' as p;

part 'video_state.dart';

class VideoCubit extends Cubit<VideoState> {
  VideoCubit() : super(VideoInitial());

  void setVideo(File video) {
    final format = _getVideoFormat(video);
    final defaultFormat = [
      'MP4',
      'MOV',
      'AVI',
      'WEBM',
    ].firstWhere((el) => el != format);
    emit(
      VideoLoaded(video: video, fromFormat: format, toFormat: defaultFormat),
    );
  }

  void setFormats({required String from, required String to}) {
    if (state is VideoLoaded) {
      final current = state as VideoLoaded;
      emit(current.copyWith(fromFormat: from, toFormat: to));
    }
  }

  Future<String?> convertVideo() async {
    if (state is! VideoLoaded) return null;

    final current = state as VideoLoaded;
    final inputPath = current.video.path;

    final appDoc = await getApplicationDocumentsDirectory();
    final convertedDir = Directory('${appDoc.path}/converted');
    if (!convertedDir.existsSync()) convertedDir.createSync(recursive: true);

    final outputName =
        '${p.basenameWithoutExtension(inputPath)}_converted.${current.toFormat.toLowerCase()}';
    final outputPath = p.join(convertedDir.path, outputName);

    late final String command;

    switch (current.toFormat.toUpperCase()) {
      case 'MP4':
        command =
            '-y -i "$inputPath" -c:v libx264 -c:a aac -strict experimental "$outputPath"';
        break;
      case 'WEBM':
        command = '-y -i "$inputPath" -c:v libvpx -c:a libvorbis "$outputPath"';
        break;
      case 'MOV':
        command = '-y -i "$inputPath" -c:v prores_ks -c:a aac "$outputPath"';
        break;
      case 'AVI':
        command =
            '-y -i "$inputPath" -c:v mpeg4 -vtag xvid -c:a mp3 "$outputPath"';
        break;
      default:
        throw UnsupportedError('Формат ${current.toFormat} не поддерживается');
    }

    try {
      final session = await FFmpegKit.execute(command);
      final logs = await session.getAllLogs();
      for (var log in logs) {
        print('LOGGG: ${log.getMessage()}');
      }
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        final outputFile = File(outputPath);

        await SaverGallery.saveFile(
          filePath: outputFile.path,
          fileName: outputName,
          skipIfExists: true,
        );

        if (await outputFile.exists()) return outputPath;
      } else {
        emit(VideoError('FFmpeg завершился с ошибкой: $returnCode'));
      }
      return null;
    } catch (e) {
      emit(VideoError('Ошибка конвертации: $e'));
      return null;
    }
  }

  String _getVideoFormat(File file) {
    final ext = file.path.split('.').last.toLowerCase();
    switch (ext) {
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'webm':
        return ext.toUpperCase();
      default:
        return 'UNKNOWN';
    }
  }
}
