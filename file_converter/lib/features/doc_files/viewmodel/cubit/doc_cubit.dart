import 'dart:io';

import 'package:docx_template/docx_template.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;
import 'package:syncfusion_flutter_pdf/pdf.dart';

part 'doc_state.dart';

class DocumentCubit extends Cubit<DocumentState> {
  DocumentCubit() : super(DocumentInitial());

  void setDocument(File file) {
    emit(
      DocumentLoaded(
        file: file,
        fromFormat: p.extension(file.path).replaceAll('.', '').toUpperCase(),
        toFormat: 'PDF',
      ),
    );
  }

  void setFormats({required String from, required String to}) {
    if (state is DocumentLoaded) {
      final current = state as DocumentLoaded;
      emit(current.copyWith(fromFormat: from, toFormat: to));
    }
  }

  Future<String?> convertDocument() async {
    if (state is! DocumentLoaded) return null;

    final current = state as DocumentLoaded;
    final inputPath = current.file.path;
    final outputDir = p.dirname(inputPath);
    final outputName =
        '${p.basenameWithoutExtension(inputPath)}_converted.${current.toFormat.toLowerCase()}';
    final outputPath = p.join(outputDir, outputName);

    try {
      if (current.fromFormat == 'TXT' && current.toFormat == 'PDF') {
        final txt = await File(inputPath).readAsString();
        final pdf = pw.Document();
        pdf.addPage(pw.Page(build: (pw.Context context) => pw.Text(txt)));
        final outFile = File(outputPath);
        await outFile.writeAsBytes(await pdf.save());
        return outputPath;
      }

      if (current.fromFormat == 'PDF' && current.toFormat == 'TXT') {
        final bytes = await File(inputPath).readAsBytes();
        final pdf = PdfDocument(inputBytes: bytes);
        final extractor = PdfTextExtractor(pdf);
        final text = extractor.extractText();
        final outFile = File(outputPath);
        await outFile.writeAsString(text);
        pdf.dispose();
        return outputPath;
      }

      if (current.fromFormat == 'TXT' && current.toFormat == 'DOCX') {
        final txt = await File(inputPath).readAsString();
        final docx = await DocxTemplate.fromBytes(
          File('template.docx').readAsBytesSync(),
        );
        final content = Content()..add(TextContent("body", txt));
        final outBytes = await docx.generate(content);
        final outFile = File(outputPath);
        await outFile.writeAsBytes(outBytes!);
        return outputPath;
      }

      emit(DocumentError('Комбинация форматов не поддерживается оффлайн'));
      return null;
    } catch (e) {
      emit(DocumentError('Ошибка конвертации: $e'));
      return null;
    }
  }
}
