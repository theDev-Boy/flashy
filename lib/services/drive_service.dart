import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import '../models/drive_file.dart';
import '../constants/drive_constants.dart';

class DriveService {
  final drive.DriveApi _driveApi;

  DriveService(this._driveApi);

  Future<List<DriveFile>> listFiles(String? folderId) async {
    try {
      final query = folderId != null
          ? "'$folderId' in parents and trashed = false"
          : "name = '${DriveConstants.flashyRootFolder}' and trashed = false";

      final response = await _driveApi.files.list(
        q: query,
        spaces: 'drive',
        pageSize: DriveConstants.itemsPerPage,
        $fields:
            'files(id, name, mimeType, parents, size, modifiedTime, createdTime, thumbnailLink, webContentLink)',
        orderBy: 'folder,modifiedTime desc',
      );

      final files = response.files ?? [];

      if (folderId == null) {
        // Looking for root Flashy folder
        if (files.isEmpty) {
          final createdFolder = await createFolder(DriveConstants.flashyRootFolder, null);
          return [createdFolder];
        }
        // Return root folder contents
        final rootFolder = files.first;
        return listFiles(rootFolder.id);
      }

      return files.map((f) {
        return DriveFile(
          id: f.id!,
          name: f.name ?? '',
          mimeType: f.mimeType,
          parentId: f.parents?.isNotEmpty == true ? f.parents!.first : null,
          size: f.size != null ? int.tryParse(f.size!) : null,
          modifiedTime: f.modifiedTime,
          createdTime: f.createdTime,
          thumbnailLink: f.thumbnailLink,
          webContentLink: f.webContentLink,
          isFolder: f.mimeType == DriveConstants.appFolderMimeType,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<DriveFile> createFolder(String name, String? parentId) async {
    final folder = drive.File()
      ..name = name
      ..mimeType = DriveConstants.appFolderMimeType
      ..parents = parentId != null ? [parentId] : [];

    final result = await _driveApi.files.create(folder);
    return DriveFile(
      id: result.id!,
      name: result.name ?? name,
      mimeType: result.mimeType,
      parentId: result.parents?.isNotEmpty == true ? result.parents!.first : null,
      createdTime: result.createdTime,
      isFolder: true,
    );
  }

  Future<String> uploadFile({
    required String localPath,
    required String parentFolderId,
    required Function(int sent, int total) onProgress,
  }) async {
    final file = File(localPath);
    final fileSize = await file.length();
    final mimeType = lookupMimeType(localPath) ?? 'application/octet-stream';

    final driveFile = drive.File()
      ..name = p.basename(localPath)
      ..parents = [parentFolderId];

    int bytesSent = 0;
    final stream = file.openRead().map((chunk) {
      bytesSent += chunk.length;
      onProgress(bytesSent, fileSize);
      return chunk;
    });

    final media = drive.Media(stream, fileSize, contentType: mimeType);

    final result = await _driveApi.files.create(
      driveFile,
      uploadMedia: media,
    );

    return result.id!;
  }

  Future<File> downloadFile(String fileId, String localPath,
      {Function(int, int)? onProgress}) async {
    final response = await _driveApi.files.get(
      fileId,
      acknowledgeAbuse: true,
    ) as drive.File;

    final file = File(localPath);

    final downloadResponse = await _driveApi.files.get(
      fileId,
      acknowledgeAbuse: true,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media?;

    if (downloadResponse != null) {
      final sink = file.openWrite();
      int received = 0;
      final totalSize =
          response.size != null ? int.tryParse(response.size!) ?? 0 : 0;
      await for (final chunk in downloadResponse.stream) {
        received += chunk.length;
        sink.add(chunk);
        onProgress?.call(received, totalSize);
      }
      await sink.close();
    }

    return file;
  }

  Future<void> deleteFile(String fileId) async {
    await _driveApi.files.delete(fileId);
  }

  Future<void> permanentlyDelete(String fileId) async {
    await _driveApi.files.delete(fileId);
  }

  Future<DriveFile> renameFile(String fileId, String newName) async {
    final updated = drive.File()..name = newName;
    final result = await _driveApi.files.update(updated, fileId);
    return DriveFile(
      id: result.id!,
      name: result.name ?? newName,
      mimeType: result.mimeType,
    );
  }

  Future<DriveFile> copyFile(String fileId, String newName,
      String? parentId) async {
    final copy = drive.File()
      ..name = newName
      ..parents = parentId != null ? [parentId] : [];

    final result = await _driveApi.files.copy(copy, fileId);
    return DriveFile(
      id: result.id!,
      name: result.name ?? newName,
      mimeType: result.mimeType,
      parentId: result.parents?.isNotEmpty == true ? result.parents!.first : null,
    );
  }

  Future<void> moveFile(String fileId, String newParentId) async {
    final updated = drive.File()..parents = [newParentId];
    await _driveApi.files.update(updated, fileId);
  }

  Future<drive.About> getQuota() async {
    return _driveApi.about.get();
  }
}
