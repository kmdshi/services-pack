import 'dart:io';

import 'package:file_converter/core/widgets/fromat_selector.dart';
import 'package:file_converter/features/audio_files/viewmodel/cubit/audio_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

class AudioTab extends StatefulWidget {
  const AudioTab({super.key});

  @override
  State<AudioTab> createState() => _AudioTabState();
}

class _AudioTabState extends State<AudioTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AudioCubit, AudioState>(
        builder: (context, state) {
          return Column(
            children: [
              const SizedBox(height: 16),
              if (state is AudioInitial) ...[
                FormatSelector(
                  formats: ['MP3', 'WAV', 'AAC'],
                  fromSelect: 'MP3',
                  toSelect: 'WAV',
                ),
                const SizedBox(height: 16),
              ],
              if (state is AudioLoaded) ...[
                Text('Выбрано: ${state.audio.path}', maxLines: 1),
                const SizedBox(height: 16),
                FormatSelector(
                  formats: ['MP3', 'WAV', 'AAC'],
                  fromSelect: state.fromFormat,
                  toSelect: state.toFormat,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final path = await context
                        .read<AudioCubit>()
                        .convertAudio();
                    if (path != null) OpenFile.open(path);
                  },
                  child: const Text('Конвертировать'),
                ),
              ],
              ElevatedButton(
                onPressed: () async => await _pickAudio(),
                child: const Text('Выбрать аудио'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (!mounted) return;

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      context.read<AudioCubit>().setAudio(file);
    }
  }
}
