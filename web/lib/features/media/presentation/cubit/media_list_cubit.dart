import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/media_file.dart';
import '../../domain/usecases/delete_media_usecase.dart';
import '../../domain/usecases/get_media_folders_usecase.dart';
import '../../domain/usecases/get_media_list_usecase.dart';
import '../../domain/usecases/update_media_usecase.dart';
import '../../domain/usecases/upload_media_usecase.dart';

part 'media_list_state.dart';
part 'media_list_cubit.freezed.dart';

/// Cubit untuk mengelola state halaman daftar media.
class MediaListCubit extends Cubit<MediaListState> {
  final GetMediaListUseCase _getMediaListUseCase;
  final GetMediaFoldersUseCase _getMediaFoldersUseCase;
  final UploadMediaUseCase _uploadMediaUseCase;
  final UpdateMediaUseCase _updateMediaUseCase;
  final DeleteMediaUseCase _deleteMediaUseCase;

  MediaListCubit({
    required GetMediaListUseCase getMediaListUseCase,
    required GetMediaFoldersUseCase getMediaFoldersUseCase,
    required UploadMediaUseCase uploadMediaUseCase,
    required UpdateMediaUseCase updateMediaUseCase,
    required DeleteMediaUseCase deleteMediaUseCase,
  })  : _getMediaListUseCase = getMediaListUseCase,
        _getMediaFoldersUseCase = getMediaFoldersUseCase,
        _uploadMediaUseCase = uploadMediaUseCase,
        _updateMediaUseCase = updateMediaUseCase,
        _deleteMediaUseCase = deleteMediaUseCase,
        super(const MediaListState.initial());

  /// Memuat daftar file media dan folder.
  Future<void> loadMedia({
    String? search,
    String? mimeType,
    String? folder,
  }) async {
    emit(const MediaListState.loading());

    final mediaResult = await _getMediaListUseCase(
      search: search,
      mimeType: mimeType,
      folder: folder,
    );
    final foldersResult = await _getMediaFoldersUseCase();

    mediaResult.fold(
      (failure) => emit(MediaListState.error(failure.message)),
      (files) {
        final List<String> folderList = foldersResult.fold(
          (_) => <String>[],
          (folders) => folders,
        );
        emit(MediaListState.loaded(
          files: files,
          folders: folderList,
          searchQuery: search ?? '',
          mimeTypeFilter: mimeType,
          folderFilter: folder,
        ));
      },
    );
  }

  /// Mengunggah file media baru.
  Future<bool> uploadMedia(Map<String, dynamic> data) async {
    final result = await _uploadMediaUseCase(data);

    return result.fold(
      (failure) {
        emit(MediaListState.error(failure.message));
        return false;
      },
      (_) {
        _reloadCurrent();
        return true;
      },
    );
  }

  /// Memperbarui metadata file media.
  Future<bool> updateMedia(String id, Map<String, dynamic> data) async {
    final result = await _updateMediaUseCase(id, data);

    return result.fold(
      (failure) {
        emit(MediaListState.error(failure.message));
        return false;
      },
      (_) {
        _reloadCurrent();
        return true;
      },
    );
  }

  /// Menghapus file media berdasarkan [id].
  Future<bool> deleteMedia(String id) async {
    final result = await _deleteMediaUseCase(id);

    return result.fold(
      (failure) {
        emit(MediaListState.error(failure.message));
        return false;
      },
      (_) {
        _reloadCurrent();
        return true;
      },
    );
  }

  /// Reload data dengan filter saat ini.
  void _reloadCurrent() {
    final currentState = state;
    if (currentState is MediaListLoaded) {
      loadMedia(
        search: currentState.searchQuery.isNotEmpty
            ? currentState.searchQuery
            : null,
        mimeType: currentState.mimeTypeFilter,
        folder: currentState.folderFilter,
      );
    } else {
      loadMedia();
    }
  }
}
