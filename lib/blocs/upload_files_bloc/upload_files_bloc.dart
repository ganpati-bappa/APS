import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'upload_files_event.dart';
part 'upload_files_state.dart';

class UploadFilesBloc extends Bloc<UploadFilesEvent, UploadFilesState> {
  final UserRepository userRepository;
  UploadFilesBloc({
    required this.userRepository
  }) : super(UploadFilesInitial()) {
    
    on<UploadImageEvent>((event, emit) async {
      emit(FilesLoading());
      try {
        String userImage = await userRepository.uploadImage(event.pathId);
        emit(FilesLoaded(imagePath: userImage));
      } catch (ex) {
        emit(FilesLoadError());
        log(ex.toString());
      }
    });
  }
}
