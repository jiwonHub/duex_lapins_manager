import 'package:duex_lapins_manager/core/di/providers.dart';
import 'package:duex_lapins_manager/domain/models/admin_store_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsViewModelProvider =
    NotifierProvider<SettingsViewModel, AdminStoreSettings>(SettingsViewModel.new);

class SettingsViewModel extends Notifier<AdminStoreSettings> {
  @override
  AdminStoreSettings build() {
    return ref.read(adminRepositoryProvider).getSettings();
  }

  void save(AdminStoreSettings settings) {
    final repository = ref.read(adminRepositoryProvider);
    repository.saveSettings(settings);
    state = repository.getSettings();
  }
}
