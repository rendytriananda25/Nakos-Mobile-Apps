import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Terjadi kesalahan pada penyimpanan lokal.']);
}

class SyncFailure extends Failure {
  const SyncFailure([super.message = 'Gagal melakukan sinkronisasi data.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Input data tidak valid.']);
}
