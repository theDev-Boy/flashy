import 'package:mime/mime.dart';

class MimeUtils {
  MimeUtils._();

  static String getMimeType(String fileName) {
    return lookupMimeType(fileName) ?? 'application/octet-stream';
  }

  static bool isImage(String mimeType) {
    return mimeType.startsWith('image/');
  }

  static bool isVideo(String mimeType) {
    return mimeType.startsWith('video/');
  }

  static bool isAudio(String mimeType) {
    return mimeType.startsWith('audio/');
  }

  static bool isDocument(String mimeType) {
    const docs = [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'text/plain',
      'text/csv',
    ];
    return docs.contains(mimeType);
  }

  static bool isText(String mimeType) {
    return mimeType.startsWith('text/');
  }

  static bool isArchive(String mimeType) {
    const archives = [
      'application/zip',
      'application/x-rar-compressed',
      'application/x-7z-compressed',
      'application/x-tar',
      'application/gzip',
      'application/x-bzip2',
    ];
    return archives.contains(mimeType);
  }
}
