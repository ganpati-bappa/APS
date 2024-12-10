part of 'upload_files_bloc.dart';

sealed class UploadFilesState extends Equatable {
  const UploadFilesState();
  
  @override
  List<Object> get props => [];
}

final class UploadFilesInitial extends UploadFilesState {}
final class FilesLoading extends UploadFilesState {}
final class FilesLoaded extends UploadFilesState {
  final String imagePath;
  const FilesLoaded({required this.imagePath});
}
final class FilesLoadError extends UploadFilesState {}
