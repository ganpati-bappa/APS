import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';

part 'pdf_viewer_event.dart';
part 'pdf_viewer_state.dart';

class PdfViewerBloc extends Bloc<PdfViewerEvent, PdfViewerState> {
  PdfViewerBloc() : super(PdfViewerInitial()) {
    on<PdfLoadingRequired>((event, emit) async {
      emit(PdfLoading());
      try {
        final Directory cacheDir = await getTemporaryDirectory();
        final String localFilePath = '${cacheDir.path}/temporary_downloaded.pdf';
        await Dio().download(event.url, localFilePath, onReceiveProgress: (value, key) { print('$value $key');});
        emit(PdfLoaded(localFilePath: localFilePath));
      } catch (ex) {
        log(ex.toString());
        print(ex.toString());
      }
    });
  }
}
