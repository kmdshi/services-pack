import 'dart:io';

import 'package:file_converter/core/widgets/fromat_selector.dart';
import 'package:file_converter/features/video_files/viewmodel/cubit/video_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class VideoTab extends StatefulWidget {
  const VideoTab({super.key});

  @override
  State<VideoTab> createState() => _VideoTabState();
}

class _VideoTabState extends State<VideoTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<VideoCubit, VideoState>(
        builder: (context, state) {
          return Column(
            children: [
              const SizedBox(height: 16),
              if (state is VideoInitial) ...[
                const SizedBox(height: 16),
                FormatSelector(
                  formats: ['MP4', 'MOV', 'AVI', 'WEBM'],
                  fromSelect: 'MP4',
                  toSelect: 'MOV',
                ),
                const SizedBox(height: 16),
              ],
              if (state is VideoLoaded) ...[
                Text('Выбрано видео: ${state.video.path}', maxLines: 1),
                const SizedBox(height: 16),
                FormatSelector(
                  key: ValueKey('${state.fromFormat}-${state.toFormat}'),
                  formats: ['MP4', 'MOV', 'AVI', 'WEBM'],
                  fromSelect: state.fromFormat,
                  toSelect: state.toFormat,
                  onChange: (from, to) =>
                      context.read<VideoCubit>().setFormats(from: from, to: to),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final path = await context
                        .read<VideoCubit>()
                        .convertVideo();
                    if (path != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Конвертация завершена! Файл сохранён.',
                          ),
                          duration: Duration(seconds: 3),
                          action: SnackBarAction(
                            label: 'Открыть',
                            onPressed: () => OpenFile.open(path),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Конвертировать'),
                ),
              ],
              ElevatedButton(
                onPressed: () async => await _pickVideo(),
                child: const Text('Выбрать видео'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (!mounted) return;

    if (pickedFile != null) {
      context.read<VideoCubit>().setVideo(File(pickedFile.path));
    }
  }
}
