import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../constants/app_constants.dart';
import '../../errors/exceptions.dart';

class LocalStorageService {
  File? _cachedFile;

  Future<File> _getLocalFile() async {
    if (_cachedFile != null) return _cachedFile!;
    try {
      final directory = await getApplicationDocumentsDirectory();
      _cachedFile = File('${directory.path}/${AppConstants.localFileName}');
      return _cachedFile!;
    } catch (e) {
      throw StorageException('Gagal mengakses direktori dokumen: $e');
    }
  }

  /// Reads raw map payload from local storage.
  /// Returns null if file does not exist.
  Future<Map<String, dynamic>?> readData() async {
    try {
      final file = await _getLocalFile();
      if (!await file.exists()) {
        return null;
      }
      final contents = await file.readAsString();
      if (contents.trim().isEmpty) {
        return null;
      }
      final decoded = jsonDecode(contents);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (e) {
      throw StorageException('Gagal membaca data dari penyimpanan lokal: $e');
    }
  }

  /// Writes entire payload Map to local storage JSON file atomically.
  Future<void> writeData(Map<String, dynamic> data) async {
    try {
      final file = await _getLocalFile();
      // Ensure metadata timestamp is updated
      data['lastModifiedTimestamp'] = DateTime.now().toUtc().toIso8601String();
      data['schemaVersion'] = AppConstants.currentSchemaVersion;

      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString, flush: true);
    } catch (e) {
      throw StorageException('Gagal menyimpan data ke disk lokal: $e');
    }
  }

  /// Clears local data (e.g. for full reset).
  Future<void> clearData() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw StorageException('Gagal menghapus cache data lokal: $e');
    }
  }

  /// Automatically strips any legacy mock/dummy data from storage.
  Future<void> cleanLegacyDummyData() async {
    try {
      final data = await readData();
      if (data == null) return;
      bool modified = false;

      if (data['transactions'] is List) {
        final txs = (data['transactions'] as List)
            .where((tx) =>
                tx is Map &&
                !['tx_01', 'tx_02', 'tx_03', 'tx_04'].contains(tx['id']))
            .toList();
        if (txs.length != (data['transactions'] as List).length) {
          data['transactions'] = txs;
          modified = true;
        }
      }

      if (data['budgetConfig'] is Map) {
        final config = data['budgetConfig'] as Map<String, dynamic>;
        if (config['mandatoryExpenses'] is List) {
          final mand = (config['mandatoryExpenses'] as List)
              .where((m) =>
                  m is Map &&
                  !['mand_01', 'mand_02', 'mand_03', 'mand_04']
                      .contains(m['id']))
              .toList();
          if (mand.length != (config['mandatoryExpenses'] as List).length) {
            config['mandatoryExpenses'] = mand;
            modified = true;
          }
        }
        if (config['monthlyIncome'] == 2500000.0 &&
            config['savingsTarget'] == 150000.0 &&
            (config['mandatoryExpenses'] as List?)?.isEmpty == true) {
          config['monthlyIncome'] = 0.0;
          config['savingsTarget'] = 0.0;
          modified = true;
        }
      }

      if (modified) {
        await writeData(data);
      }
    } catch (_) {}
  }
  /// Returns the target nakos backup directory in the user's storage.
  /// Priority:
  /// 1. /storage/emulated/0/Documents/nakos (standard public Android Documents directory)
  /// 2. /sdcard/Documents/nakos
  /// 3. App External Documents/nakos
  /// 4. App Internal Documents/nakos
  Future<Directory> getNakosDocumentsDirectory() async {
    final candidatePaths = [
      '/storage/emulated/0/Documents/nakos',
      '/sdcard/Documents/nakos',
    ];

    for (final path in candidatePaths) {
      try {
        final dir = Directory(path);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        final probeFile = File('${dir.path}/.probe_nakos');
        await probeFile.writeAsString('test');
        await probeFile.delete();
        return dir;
      } catch (_) {}
    }

    try {
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        final dir = Directory('${extDir.path}/Documents/nakos');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        return dir;
      }
    } catch (_) {}

    final appDocDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDocDir.path}/nakos');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Saves backup copy directly to Documents/nakos/nakos_backup.json
  /// and updates internal storage as well.
  Future<File> saveBackupToDocuments(Map<String, dynamic> data) async {
    await writeData(data);
    try {
      final nakosDir = await getNakosDocumentsDirectory();
      final backupFile = File('${nakosDir.path}/nakos_backup.json');
      data['lastBackupTimestamp'] = DateTime.now().toUtc().toIso8601String();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      await backupFile.writeAsString(jsonString, flush: true);
      return backupFile;
    } catch (e) {
      throw StorageException('Gagal membuat file cadangan di folder Dokumen/nakos: $e');
    }
  }

  /// Automatically scans standard storage locations for the nakos backup file.
  /// Returns the File if found and valid, otherwise null.
  Future<File?> scanBackupInDocuments() async {
    final candidatePaths = [
      '/storage/emulated/0/Documents/nakos/nakos_backup.json',
      '/sdcard/Documents/nakos/nakos_backup.json',
    ];

    try {
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        candidatePaths.add('${extDir.path}/Documents/nakos/nakos_backup.json');
      }
    } catch (_) {}

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      candidatePaths.add('${appDocDir.path}/nakos/nakos_backup.json');
      candidatePaths.add('${appDocDir.path}/nakos_backup.json');
    } catch (_) {}

    for (final path in candidatePaths) {
      final file = File(path);
      if (await file.exists()) {
        try {
          final content = await file.readAsString();
          if (content.trim().isNotEmpty) {
            final decoded = jsonDecode(content);
            if (decoded is Map<String, dynamic>) {
              return file;
            }
          }
        } catch (_) {}
      }
    }
    return null;
  }

  /// Restores data from the scanned backup file into the app storage.
  Future<Map<String, dynamic>> restoreFromBackup(File backupFile) async {
    try {
      final content = await backupFile.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) {
        throw StorageException('Format file backup tidak valid.');
      }
      await writeData(decoded);
      return decoded;
    } catch (e) {
      throw StorageException('Gagal memulihkan data dari cadangan: $e');
    }
  }
}
