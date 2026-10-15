import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nakos/core/services/local_storage/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('nakos_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async => tempDir.path,
    );
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('LocalStorageService Backup & Repair Tests', () {
    test('can save backup and retrieve it via scanBackupInDocuments', () async {
      final storage = LocalStorageService();
      final sampleData = <String, dynamic>{
        'profile': {'name': 'Rendy Test'},
        'transactions': [
          {
            'id': 'tx_99',
            'title': 'Makan Siang',
            'amount': 25000.0,
            'category': 'food',
            'timestamp': DateTime.now().toIso8601String(),
          }
        ],
        'budgetConfig': {
          'monthlyIncome': 3000000.0,
          'savingsTarget': 300000.0,
        }
      };

      final file = await storage.saveBackupToDocuments(sampleData);
      expect(await file.exists(), isTrue);

      final scannedFile = await storage.scanBackupInDocuments();
      expect(scannedFile, isNotNull);
      expect(await scannedFile!.exists(), isTrue);

      final content = await scannedFile.readAsString();
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      expect(decoded['profile']['name'], 'Rendy Test');

      final restored = await storage.restoreFromBackup(scannedFile);
      expect(restored['profile']['name'], 'Rendy Test');
    });
  });
}
