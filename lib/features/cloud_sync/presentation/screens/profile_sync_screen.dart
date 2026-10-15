import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_typography.dart';
import '../../../../core/services/local_storage/local_storage_service.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_event.dart';

class ProfileSyncScreen extends StatefulWidget {
  const ProfileSyncScreen({super.key});

  @override
  State<ProfileSyncScreen> createState() => _ProfileSyncScreenState();
}

class _ProfileSyncScreenState extends State<ProfileSyncScreen> {
  bool _isSyncing = false;
  bool _isScanning = false;
  String _lastSyncText = 'Hari ini, 12:40';
  String _backupSize = '42 KB';

  String _userName = 'Anak Kost';
  String? _avatarUrl;

  bool _deficitWarning = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final storage = LocalStorageService();
    final data = await storage.readData();
    if (data != null) {
      if (data.containsKey('profile')) {
        final profile = data['profile'] as Map<String, dynamic>;
        _userName = profile['name'] as String? ?? 'Anak Kost';
        _avatarUrl = profile['photoUrl'] as String?;
        _deficitWarning = profile['deficitWarning'] as bool? ?? true;
        _lastSyncText = profile['lastSyncText'] as String? ?? 'Hari ini, 12:40';
      }
      _backupSize = await _calculateBackupSize();
      if (mounted) setState(() {});
    }
  }

  Future<String> _calculateBackupSize() async {
    final storage = LocalStorageService();
    final data = await storage.readData();
    if (data == null) return '42 KB';
    final bytes = utf8.encode(jsonEncode(data)).length;
    final kb = (bytes / 1024).clamp(1.2, 9999.0);
    return '${kb.toStringAsFixed(1)} KB';
  }

  Future<void> _saveProfileSettings() async {
    final storage = LocalStorageService();
    final data = await storage.readData() ?? <String, dynamic>{};
    data['profile'] = {
      'name': _userName,
      'photoUrl': _avatarUrl,
      'deficitWarning': _deficitWarning,
      'lastSyncText': _lastSyncText,
    };
    await storage.writeData(data);
  }

  Future<void> _saveBackupToDocuments() async {
    setState(() => _isSyncing = true);
    HapticFeedback.mediumImpact();

    try {
      final storage = LocalStorageService();
      final data = await storage.readData() ?? <String, dynamic>{};
      data['profile'] = {
        'name': _userName,
        'photoUrl': _avatarUrl,
        'deficitWarning': _deficitWarning,
        'lastSyncText': _lastSyncText,
      };

      await storage.saveBackupToDocuments(data);
      final now = DateTime.now();
      final timeStr =
          'Hari ini, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      _backupSize = await _calculateBackupSize();

      if (!mounted) return;
      setState(() {
        _isSyncing = false;
        _lastSyncText = timeStr;
      });
      await _saveProfileSettings();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Cadangan tersimpan di Dokumen/nakos/nakos_backup.json ($_backupSize)',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.surfaceCard,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan cadangan: $e'),
          backgroundColor: AppColors.expenseRed,
        ),
      );
    }
  }

  Future<void> _repairDataFromDocuments() async {
    setState(() => _isScanning = true);
    HapticFeedback.lightImpact();

    try {
      final storage = LocalStorageService();
      final backupFile = await storage.scanBackupInDocuments();

      if (!mounted) return;
      setState(() => _isScanning = false);

      if (backupFile == null || !await backupFile.exists()) {
        _showBackupNotFoundDialog();
        return;
      }

      final fileSize = (await backupFile.length() / 1024).clamp(1.0, 9999.0);
      final lastModified = await backupFile.lastModified();
      final contentStr = await backupFile.readAsString();
      final decoded = jsonDecode(contentStr) as Map<String, dynamic>;

      int txCount = 0;
      if (decoded['transactions'] is List) {
        txCount = (decoded['transactions'] as List).length;
      }
      String backupUserName = _userName;
      if (decoded['profile'] is Map && decoded['profile']['name'] != null) {
        backupUserName = decoded['profile']['name'] as String;
      }

      if (!mounted) return;
      _showBackupFoundDialog(
        backupFile: backupFile,
        fileSizeKb: '${fileSize.toStringAsFixed(1)} KB',
        lastModified: lastModified,
        txCount: txCount,
        backupUserName: backupUserName,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isScanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat memindai: $e'),
          backgroundColor: AppColors.expenseRed,
        ),
      );
    }
  }

  void _showBackupNotFoundDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: AppColors.borderHairline),
          ),
          title: Row(
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: AppColors.expenseSurface,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  color: AppColors.expenseRed,
                  size: 22.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  'Backup Tidak Ditemukan',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textHighContrast,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sistem telah otomatis memindai folder Dokumen/nakos, namun tidak menemukan file cadangan "nakos_backup.json".',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceInteractive,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.folder_open_rounded,
                      color: AppColors.brandAccentGold,
                      size: 20.0,
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        'Lokasi: Dokumen/nakos/nakos_backup.json',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textHighContrast,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                'Tips: Tekan tombol "Simpan" terlebih dahulu untuk membuat file cadangan baru di Dokumen/nakos.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPlaceholder,
                  fontSize: 11.0,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Tutup',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _saveBackupToDocuments();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('Simpan Sekarang'),
            ),
          ],
        );
      },
    );
  }

  void _showBackupFoundDialog({
    required File backupFile,
    required String fileSizeKb,
    required DateTime lastModified,
    required int txCount,
    required String backupUserName,
  }) {
    final dateStr =
        '${lastModified.day.toString().padLeft(2, '0')}/${lastModified.month.toString().padLeft(2, '0')}/${lastModified.year} ${lastModified.hour.toString().padLeft(2, '0')}:${lastModified.minute.toString().padLeft(2, '0')}';

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: AppColors.borderHairline),
          ),
          title: Row(
            children: [
              Container(
                width: 38.0,
                height: 38.0,
                decoration: BoxDecoration(
                  color: AppColors.incomeSurface,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: AppColors.incomeGreen,
                  size: 22.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  'File Backup Ditemukan',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textHighContrast,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'File cadangan berhasil dipindai dan siap digunakan untuk repair data:',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14.0),
              Container(
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceInteractive,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: AppColors.borderHairline,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lokasi',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.0,
                          ),
                        ),
                        Text(
                          'Dokumen/nakos',
                          style: TextStyle(
                            color: AppColors.textHighContrast,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ukuran File',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.0,
                          ),
                        ),
                        Text(
                          fileSizeKb,
                          style: TextStyle(
                            color: AppColors.brandAccentGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Terakhir Disimpan',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.0,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: TextStyle(
                            color: AppColors.textHighContrast,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Data Transaksi',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.0,
                          ),
                        ),
                        Text(
                          '$txCount transaksi',
                          style: TextStyle(
                            color: AppColors.incomeGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14.0),
              Text(
                'Lanjutkan repair untuk memulihkan seluruh catatan keuangan dari file ini?',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textHighContrast,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                await _performRestore(backupFile);
              },
              icon: const Icon(Icons.build_rounded, size: 16.0),
              label: const Text('Repair Sekarang'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performRestore(File backupFile) async {
    setState(() => _isSyncing = true);
    HapticFeedback.mediumImpact();

    try {
      final storage = LocalStorageService();
      final restoredData = await storage.restoreFromBackup(backupFile);

      if (restoredData.containsKey('profile')) {
        final profile = restoredData['profile'] as Map<String, dynamic>;
        _userName = profile['name'] as String? ?? 'Anak Kost';
        _avatarUrl = profile['photoUrl'] as String?;
        _deficitWarning = profile['deficitWarning'] as bool? ?? true;
        _lastSyncText = profile['lastSyncText'] as String? ?? _lastSyncText;
      }
      _backupSize = await _calculateBackupSize();

      if (!mounted) return;
      setState(() => _isSyncing = false);

      context.read<DashboardBloc>().add(const RefreshDashboardEvent());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✓ Sukses! Seluruh data keuangan berhasil di-repair dari Dokumen/nakos.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.surfaceCard,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal melakukan repair data: $e'),
          backgroundColor: AppColors.expenseRed,
        ),
      );
    }
  }



  Future<void> _pickAndSaveImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );

      if (pickedFile == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final targetFile = File('${appDir.path}/nakos_profile_avatar.jpg');

      // Copy permanently to internal app document storage
      await File(pickedFile.path).copy(targetFile.path);

      // Invalidate image cache so Flutter immediately paints the new image
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      setState(() {
        _avatarUrl = targetFile.path;
      });

      await _saveProfileSettings();
      if (mounted) {
        context.read<DashboardBloc>().add(const RefreshDashboardEvent());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Foto profil berhasil disimpan permanen!'),
            backgroundColor: AppColors.surfaceCard,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih foto: $e'),
          backgroundColor: AppColors.expenseRed,
        ),
      );
    }
  }

  Future<void> _removeProfilePhoto() async {
    try {
      if (_avatarUrl != null) {
        final file = File(_avatarUrl!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      setState(() {
        _avatarUrl = null;
      });

      await _saveProfileSettings();
      if (mounted) {
        context.read<DashboardBloc>().add(const RefreshDashboardEvent());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Foto profil dihapus (menggunakan inisial nama)'),
            backgroundColor: AppColors.surfaceCard,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus foto: $e'),
          backgroundColor: AppColors.expenseRed,
        ),
      );
    }
  }

  void _showAvatarOptionsBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
            border: Border(top: BorderSide(color: AppColors.borderHairline)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceInteractive,
                      borderRadius: BorderRadius.circular(999.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Ubah Foto Profil',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textHighContrast,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Foto akan disimpan secara permanen di memori perangkat.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColors.brandAccentGoldSurface,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: AppColors.brandAccentGold),
                  ),
                  title: const Text('Pilih dari Galeri', style: TextStyle(color: AppColors.textHighContrast, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Pilih foto dari galeri HP Anda', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.0)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _pickAndSaveImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 8.0),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimarySurface,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: AppColors.brandPrimary),
                  ),
                  title: const Text('Ambil dari Kamera', style: TextStyle(color: AppColors.textHighContrast, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Buka kamera dan ambil foto baru', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.0)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    _pickAndSaveImage(ImageSource.camera);
                  },
                ),
                if (_avatarUrl != null && _avatarUrl!.isNotEmpty) ...[
                  const SizedBox(height: 8.0),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppColors.expenseSurface,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: AppColors.expenseRed),
                    ),
                    title: const Text('Hapus Foto Profil', style: TextStyle(color: AppColors.expenseRed, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Gunakan inisial nama sebagai avatar', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.0)),
                    onTap: () {
                      Navigator.pop(sheetCtx);
                      _removeProfilePhoto();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _userName);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: AppColors.borderHairline),
          ),
          title: Text(
            'Edit Profil Pengguna',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textHighContrast,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: AppColors.textHighContrast),
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.surfaceInteractive,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.brandPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text(
                'Batal',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameCtrl.text.trim();

                if (newName.isNotEmpty) {
                  setState(() {
                    _userName = newName;
                  });
                  await _saveProfileSettings();
                }
                if (dialogCtx.mounted) {
                  Navigator.pop(dialogCtx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: AppColors.borderHairline),
          ),
          title: Row(
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimarySurface,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const Icon(
                  Icons.savings_rounded,
                  color: AppColors.brandPrimary,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Text(
                'Nakos v1.0',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textHighContrast,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manajemen keuangan mandiri untuk anak kost.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textHighContrast,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                '• 100% Offline-First & Penyimpanan Lokal Aman\n• Barometer Survival Anggaran Harian\n• Desain Obsidian & Soft Iris',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Tutup',
                style: TextStyle(color: AppColors.brandPrimary),
              ),
            ),
          ],
        );
      },
    );
  }



  Widget _buildAvatar() {
    Widget avatarContent;
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      if (_avatarUrl!.startsWith('http')) {
        avatarContent = Image.network(
          _avatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildInitials(),
        );
      } else {
        final file = File(_avatarUrl!);
        if (file.existsSync()) {
          avatarContent = Image.file(
            file,
            fit: BoxFit.cover,
            key: ValueKey('avatar_${file.lastModifiedSync().millisecondsSinceEpoch}'),
            errorBuilder: (_, _, _) => _buildInitials(),
          );
        } else {
          avatarContent = _buildInitials();
        }
      }
    } else {
      avatarContent = _buildInitials();
    }

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          GestureDetector(
            onTap: _showAvatarOptionsBottomSheet,
            child: Container(
              width: 96.0,
              height: 96.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF1A1A20), Color(0xFF000000)],
                ),
                border: Border.all(
                  color: AppColors.brandPrimary.withValues(alpha: 0.6),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandPrimary.withValues(alpha: 0.25),
                    blurRadius: 16.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: ClipOval(
                child: avatarContent,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showAvatarOptionsBottomSheet,
              child: Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.bgCanvas,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 6.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 16.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'A',
        style: const TextStyle(
          color: AppColors.brandPrimary,
          fontSize: 34.0,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildFeaturedCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status & Cadangan',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textHighContrast,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12.0),
        SizedBox(
          height: 172.0,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            children: [
              _buildCard1(),
              const SizedBox(width: 14.0),
              _buildCard2(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard1() {
    return Container(
      width: 290.0,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF000000),
            Color(0xFF18181E),
            Color(0xFF1A1A20),
          ],
        ),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A20).withValues(alpha: 0.25),
            blurRadius: 14.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15.0,
            bottom: -15.0,
            child: Icon(
              Icons.shield_rounded,
              size: 95.0,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            color: Colors.white,
                            size: 13.0,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Flexible(
                          child: Text(
                            'Cadangan Data',
                            style: AppTypography.titleSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 3.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999.0),
                    ),
                    child: Text(
                      _backupSize,
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.0,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dokumen / nakos',
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Terakhir: $_lastSyncText',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    InkWell(
                      onTap: _isSyncing ? null : _saveBackupToDocuments,
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isSyncing
                                ? const SizedBox(
                                    width: 12.0,
                                    height: 12.0,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.save_rounded,
                                    color: Colors.white,
                                    size: 13.0,
                                  ),
                            const SizedBox(width: 4.0),
                            const Text(
                              'Simpan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    InkWell(
                      onTap: _isScanning ? null : _repairDataFromDocuments,
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandPrimary.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isScanning
                                ? const SizedBox(
                                    width: 12.0,
                                    height: 12.0,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.build_rounded,
                                    color: Colors.white,
                                    size: 13.0,
                                  ),
                            const SizedBox(width: 4.0),
                            const Text(
                              'Repair Data',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard2() {
    return Container(
      width: 290.0,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A20),
            Color(0xFF121216),
            Color(0xFF000000),
          ],
        ),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.25),
            blurRadius: 14.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15.0,
            bottom: -15.0,
            child: Icon(
              Icons.warning_amber_rounded,
              size: 95.0,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.radar_rounded,
                            color: Colors.white,
                            size: 13.0,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Flexible(
                          child: Text(
                            'Proteksi Defisit',
                            style: AppTypography.titleSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 3.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999.0),
                    ),
                    child: Text(
                      _deficitWarning ? 'Aktif' : 'Nonaktif',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.0,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mode Survival Kost',
                    style: AppTypography.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Peringatan belanja tembus batas aman',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {
                    setState(() => _deficitWarning = !_deficitWarning);
                    _saveProfileSettings();
                  },
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _deficitWarning
                            ? Icons.check_circle_rounded
                            : Icons.cancel_outlined,
                        color: Colors.white,
                        size: 13.0,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        _deficitWarning ? 'Siaga Aktif' : 'Nyalakan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedMenu() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: AppColors.borderHairline,
        ),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline_rounded,
            iconColor: AppColors.brandPrimary,
            title: 'Edit Nama Profil',
            onTap: _showEditProfileDialog,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.save_rounded,
            iconColor: AppColors.incomeGreen,
            title: 'Simpan ke Dokumen/nakos',
            onTap: _isSyncing ? null : _saveBackupToDocuments,
            trailingWidget: _isSyncing
                ? const SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: AppColors.brandPrimary,
                    ),
                  )
                : null,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.build_rounded,
            iconColor: AppColors.brandPrimary,
            title: 'Repair Data (Pindai Dokumen/nakos)',
            onTap: _isScanning ? null : _repairDataFromDocuments,
            trailingWidget: _isScanning
                ? const SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: AppColors.brandPrimary,
                    ),
                  )
                : null,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFFF653F),
            title: 'Peringatan Defisit Anggaran',
            trailingWidget: Switch.adaptive(
              value: _deficitWarning,
              activeTrackColor: AppColors.brandPrimary,
              onChanged: (val) {
                setState(() => _deficitWarning = val);
                _saveProfileSettings();
              },
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.textSecondary,
            title: 'Tentang Nakos',
            onTap: _showAboutDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1.0,
      thickness: 1.0,
      indent: 56.0,
      endIndent: 16.0,
      color: AppColors.borderHairline.withValues(alpha: 0.7),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    Color? trailingColor,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Icon(icon, size: 22.0, color: iconColor),
              const SizedBox(width: 14.0),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: titleColor ?? AppColors.textHighContrast,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ),
                ),
              ),
              trailingWidget ??
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20.0,
                    color: trailingColor ?? AppColors.textPlaceholder,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.bgCanvas,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    context.read<DashboardBloc>().add(const RefreshDashboardEvent());
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textHighContrast,
                    size: 18.0,
                  ),
                ),
                Text(
                  'Profil & Cadangan',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textHighContrast,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.5,
                  ),
                ),
const SizedBox(width: 44.0),
              ],
            ),
          ),
        ),
        Expanded(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 12.0),
                    _buildAvatar(),
                    const SizedBox(height: 12.0),
                    Text(
                      _userName,
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textHighContrast,
                        fontWeight: FontWeight.w800,
                        fontSize: 22.0,
                        letterSpacing: -0.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24.0),
                    _buildFeaturedCards(),
                    const SizedBox(height: 20.0),
                    _buildGroupedMenu(),
                    const SizedBox(height: 120.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
