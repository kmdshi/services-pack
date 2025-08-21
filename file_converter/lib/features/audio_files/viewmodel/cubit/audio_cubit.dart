import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;

part 'audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  AudioCubit() : super(AudioInitial());

  void setAudio(File audio) {
    emit(
      AudioLoaded(
        audio: audio,
        fromFormat: p.extension(audio.path).replaceAll('.', '').toUpperCase(),
        toFormat: 'MP3',
      ),
    );
  }

  void setFormats({required String from, required String to}) {
    if (state is AudioLoaded) {
      final current = state as AudioLoaded;
      emit(current.copyWith(fromFormat: from, toFormat: to));
    }
  }

  Future<String?> convertAudio() async {
    if (state is! AudioLoaded) return null;

    final current = state as AudioLoaded;
    final inputPath = current.audio.path;
    final outputDir = p.dirname(inputPath);
    final outputName =
        '${p.basenameWithoutExtension(inputPath)}_converted.${current.toFormat.toLowerCase()}';
    final outputPath = p.join(outputDir, outputName);

    final command = '-i "$inputPath" "$outputPath"';

    try {
      await FFmpegKit.execute(command);
      final outputFile = File(outputPath);
      if (await outputFile.exists()) return outputPath;
      emit(AudioError('Файл не создан после конвертации'));
      return null;
    } catch (e) {
      emit(AudioError('Ошибка конвертации: $e'));
      return null;
    }
  }
}
