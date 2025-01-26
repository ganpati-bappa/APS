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
        String filePath = '/storage/emulated/0/APS/';
        if (Platform.isAndroid) {
          Directory directory = Directory(filePath);
          if (!directory.existsSync()) {
            directory.createSync(recursive: true);
          }
        }
        else  {
          Directory path = await getApplicationDocumentsDirectory();
          filePath = path.path;
        }
        Uri uri = Uri.parse(event.url);
        String? pdfToken = uri.queryParameters["token"];
        final String downloadFilePath = '$filePath/${event.pdfName}-$pdfToken.pdf';
        final File file = File(downloadFilePath);
        if (file.existsSync() && file.lengthSync() != 0) {
          emit(PdfLoaded(localFilePath: downloadFilePath));
        }
      } catch (ex) {
        log(ex.toString());
      }
      try {
        final Directory cacheDir = await getTemporaryDirectory();
        final String localFilePath =
            '${cacheDir.path}/temporary_downloaded.pdf';
        await Dio().download(event.url, localFilePath,
            onReceiveProgress: (value, key) {});
        emit(PdfLoaded(localFilePath: localFilePath));
      } catch (ex) {
        log(ex.toString());
      }
    });

    on<PDFDownloading>((event, emit) {
      emit(PDFDownloadingState());
    });

    on<PDFDownloaded>((event, emit) {
      emit(PDFDownloadedState());
    });
  }
}
