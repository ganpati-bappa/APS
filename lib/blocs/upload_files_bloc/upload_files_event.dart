part of 'upload_files_bloc.dart';

sealed class UploadFilesEvent extends Equatable {
  const UploadFilesEvent();

  @override
  List<Object> get props => [];
}

class UploadImageEvent extends UploadFilesEvent {
  final String pathId;

  const UploadImageEvent({required this.pathId});
}