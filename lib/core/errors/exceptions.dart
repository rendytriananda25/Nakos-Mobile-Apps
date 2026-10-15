class StorageException implements Exception {
  final String message;
  const StorageException([this.message = 'Terjadi kesalahan pada I/O disk lokal.']);

  @override
  String toString() => 'StorageException: $message';
}

class SyncException implements Exception {
  final String message;
  const SyncException([this.message = 'Terjadi kesalahan pada sinkronisasi data.']);

  @override
  String toString() => 'SyncException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException([this.message = 'Validasi bisnis gagal.']);

  @override
  String toString() => 'ValidationException: $message';
}
