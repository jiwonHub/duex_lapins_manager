import 'package:deux_lapins_manager/core/di/providers.dart';
import 'package:deux_lapins_manager/domain/models/admin_store_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  const SettingsState({
    required this.settings,
    this.loading = false,
    this.saving = false,
    this.errorMessage,
  });

  final AdminStoreSettings settings;
  final bool loading;
  final bool saving;
  final String? errorMessage;

  SettingsState copyWith({
    AdminStoreSettings? settings,
    bool? loading,
    bool? saving,
    String? errorMessage,
    bool clearError = false,
  }) => SettingsState(
    settings: settings ?? this.settings,
    loading: loading ?? this.loading,
    saving: saving ?? this.saving,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

final settingsViewModelProvider =
NotifierProvider<SettingsViewModel, SettingsState>(SettingsViewModel.new);

class SettingsViewModel extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    Future<void>.microtask(refresh);
    return SettingsState(settings: ref.read(adminRepositoryProvider).getSettings());
  }

  Future<void> refresh() async {
    if (state.loading || state.saving) return;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final settings = await ref.read(adminRepositoryProvider).fetchSettingsApi();
      state = state.copyWith(settings: settings, loading: false);
    } catch (error) {
      state = state.copyWith(loading: false, errorMessage: '$error');
    }
  }

  Future<void> save(AdminStoreSettings settings) async {
    if (state.loading || state.saving) {
      throw StateError('설정 저장 요청이 진행 중입니다.');
    }
    state = state.copyWith(saving: true, clearError: true);
    try {
      final saved = await ref.read(adminRepositoryProvider).saveSettingsApi(settings);
      state = state.copyWith(settings: saved, saving: false);
    } catch (error) {
      state = state.copyWith(saving: false, errorMessage: '$error');
      rethrow;
    }
  }
}