import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/local_storage/local_storage_service.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_event.dart';

class OnboardingController {
  final LocalStorageService _storage;

  OnboardingController({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService();

  Future<void> completeOnboarding(BuildContext context) async {
    HapticFeedback.mediumImpact();

    final data = await _storage.readData() ?? <String, dynamic>{};
    data['isLoggedIn'] = true;

    final profile = (data['profile'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(k, v),
    );
    profile['name'] = profile['name'] ?? 'Anak Kost';
    final now = DateTime.now();
    profile['lastSyncText'] =
        'Hari ini, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    data['profile'] = profile;

    await _storage.writeData(data);

    if (!context.mounted) return;

    context.read<DashboardBloc>().add(const RefreshDashboardEvent());
  }
}
