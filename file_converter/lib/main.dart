import 'package:file_converter/core/widgets/tabs_screen.dart';
import 'package:file_converter/features/audio_files/viewmodel/cubit/audio_cubit.dart';
import 'package:file_converter/features/doc_files/viewmodel/cubit/doc_cubit.dart';
import 'package:file_converter/features/image_files/viewmodel/cubit/image_cubit.dart';
import 'package:file_converter/features/video_files/viewmodel/cubit/video_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (ctx) => AudioCubit()),
          BlocProvider(create: (ctx) => VideoCubit()),
          BlocProvider(create: (ctx) => DocumentCubit()),
          BlocProvider(create: (ctx) => ImageCubit()),
        ],
        child: TabsScreen(),
      ),
    );
  }
}
