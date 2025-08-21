import 'dart:io';

import 'package:file_converter/core/widgets/fromat_selector.dart';
import 'package:file_converter/features/doc_files/viewmodel/cubit/doc_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';

class DocumentTab extends StatefulWidget {
  const DocumentTab({super.key});

  @override
  State<DocumentTab> createState() => _DocumentTabState();
}

class _DocumentTabState extends State<DocumentTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DocumentCubit, DocumentState>(
        builder: (context, state) {
          return Column(
            children: [
              const SizedBox(height: 16),
              if (state is DocumentInitial) ...[
                FormatSelector(
                  formats: ['TXT', 'PDF', 'DOCX'],
                  fromSelect: 'TXT',
                  toSelect: 'PDF',
                ),
                const SizedBox(height: 16),
              ],
              if (state is DocumentLoaded) ...[
                Text('Выбрано: ${state.file.path}', maxLines: 1),
                const SizedBox(height: 16),
                FormatSelector(
                  formats: ['TXT', 'PDF', 'DOCX'],
                  fromSelect: state.fromFormat,
                  toSelect: state.toFormat,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final path = await context
                        .read<DocumentCubit>()
                        .convertDocument();
                    if (path != null) OpenFile.open(path);
                  },
                  child: const Text('Конвертировать'),
                ),
              ],
              ElevatedButton(
                onPressed: () async => await _pickDocument(),
                child: const Text('Выбрать файл'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf', 'docx'],
    );

    if (!mounted) return;

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      context.read<DocumentCubit>().setDocument(file);
    }
  }
}
