import 'dart:io';

import 'package:file_converter/core/widgets/fromat_selector.dart';
import 'package:file_converter/features/image_files/viewmodel/cubit/image_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';

class ImageTab extends StatefulWidget {
  const ImageTab({super.key});

  @override
  State<ImageTab> createState() => _ImageTabState();
}

class _ImageTabState extends State<ImageTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ImageCubit, ImageState>(
        builder: (context, state) {
          return Column(
            children: [
              const SizedBox(height: 16),
              if (state is ImageInitial) ...[
                const SizedBox(height: 16),
                FormatSelector(
                  formats: ['WEBP', 'PNG', 'JPG'],
                  fromSelect: 'PNG',
                  toSelect: 'WEBP',
                ),
                const SizedBox(height: 16),
              ],
              if (state is ImageLoaded) ...[
                Image.file(state.image, height: 200),
                const SizedBox(height: 16),
                FormatSelector(
                  key: ValueKey('${state.fromFormat}-${state.toFormat}'),
                  formats: ['WEBP', 'PNG', 'JPG'],
                  fromSelect: state.fromFormat,
                  toSelect: state.toFormat,
                  onChange: (from, to) =>
                      context.read<ImageCubit>().setToFormat(from, to),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final path = await context
                        .read<ImageCubit>()
                        .convertImage();
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
                onPressed: () async => await _pickImg(),
                child: const Text('Выбрать изображение'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickImg() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (!mounted) return;

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      context.read<ImageCubit>().setImage(file);
    }
  }
}
