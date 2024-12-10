part of 'pdf_viewer_bloc.dart';

sealed class PdfViewerEvent extends Equatable {
  const PdfViewerEvent();

  @override
  List<Object> get props => [];
}

class PdfLoadingRequired extends PdfViewerEvent {
  final String url;
  const PdfLoadingRequired({required this.url});
}