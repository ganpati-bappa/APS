part of 'pdf_viewer_bloc.dart';

sealed class PdfViewerState extends Equatable {
  const PdfViewerState();
  
  @override
  List<Object> get props => [];
}

final class PdfViewerInitial extends PdfViewerState {}

final class PdfLoading extends PdfViewerState {
  
}

final class PdfLoaded extends PdfViewerState {
  final String localFilePath;
  const PdfLoaded({required this.localFilePath});
}

final class PDFDownloadingState extends PdfViewerState {}

final class PDFDownloadedState extends PdfViewerState {}